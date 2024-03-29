class CompaniesController < ApplicationController
  include FollowableController

  before_action :set_company, only: [
    :show,
    :update,
    :destroy,
    :verify_site_url,
    :download_verification_file,
    :finance,
    :settings
  ]

  load_and_authorize_resource except: [:index, :search]
  authorize_resource only: [:index, :search], class: controller_name.to_sym

  after_action :call_page_visit_to_slack_channel, only: [:index, :show]
  after_action :create_intercom_event, only: [:new, :update]

  # GET /companies
  def index
  end

  # POST /companies/search
  def search
    respond_to do |format|
      format.html { render :index }
      format.json {
        @companies = Company.search(params)
        render :index
      }
    end
  end

  # GET /companies/1
  def show
    respond_to do |format|
      format.html { pagescript_params(id: @company.id) }
      format.json {
        @company = find_company(
          Company.includes(
            :people,
            :vacancies,
            :pictures,
            :paragraphs,
            blocks: :block_identities
          )
        )
      }
    end
  end

  # GET /companies/new
  def new
    if blank_company = current_user.blank_company
      @company = blank_company
    else
      @company = current_user.companies.build
      @company.should_build_objects!
      @company.save!
    end

    redirect_to @company
  end

  # PATCH/PUT /companies/1
  def update
    @company.update!(company_params)

    update_site_url_verification(@company) if company_params[:site_url]

    respond_to do |format|
      format.json { render json: CompanySerializer.new(@company, scope: current_user) }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :fail, status: 412 }
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to main_app.companies_path, notice: t('messages.destroyed', name: t('lexicon.company'))
  end

  # GET /companies/1/finance
  def finance
  end

  # GET /companies/1/settings
  def settings
    pagescript_params(id: @company.id)
  end

  # GET /companies/1/verify_site_url
  def verify_site_url
    uri = URI.parse(@company.formatted_site_url)
    file = "#{@company.humanized_id}.txt"

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request_head("/#{file}")

    if response.code == '200'
      @company.tokens.where(name: :site_url_verification).destroy_all
      File.delete(File.join(Rails.root, 'tmp', 'verifications', "#{file}"))

      respond_to do |format|
        format.json { render json: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: :fail }
      end
    end
  end

  # GET /companies/1/download_verification_file
  def download_verification_file
    file_path = File.join(Rails.root, 'tmp', 'verifications', "#{@company.humanized_id}.txt")
    if File.exists?(file_path)
      send_file(file_path)
    else
      redirect_to :back, alert: 'Error. No such file.'
    end
  end

private

  def update_site_url_verification(company)
    return if current_user.editor?

    if company_params[:site_url] == ''
      company.tokens.where(name: :site_url_verification).destroy_all
    else
      token = Token.find_or_create_token_by!(name: :site_url_verification, owner: company, data: { user_id: current_user.id })
      dir_location = File.join(Rails.root, 'tmp', 'verifications')
      file_location = File.join(dir_location, "#{company.humanized_id}.txt")
      unless File.exists?(file_location)
        FileUtils.mkdir_p(dir_location)
        File.open(file_location, 'w') { |f| f.write("Good luck using #{ENV['SITE_NAME']}!") }
      end

      UserMailer.company_url_verification(token).deliver
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  def find_company(relation)
    relation.find_by(slug: params[:id]) || relation.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(
      :name,
      :site_url,
      :description,
      :established_on,
      :is_published,
      :logotype,
      :remove_logotype,
      :is_name_in_logo,
      :slug,
      :tag_names
    )
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @company.valid?

    event_name = if action_name == 'update' && company_params[:is_published] == 'true'
      'published-company'
    elsif action_name == 'new' && current_user.companies.any?
      'created-company'
    else
      nil
    end

    if event_name
      IntercomEventsWorker.perform_async(event_name, current_user.id, company_id: @company.id)
    end
  end

  def call_page_visit_to_slack_channel
    case action_name
    when 'index'
      page_title = 'companies list'
      page_url = main_app.companies_url
    when 'show'
      page_title = "#{@company.name}'s page"
      page_url = main_app.company_url(@company)
    end

    post_page_visit_to_slack_channel(page_title, page_url)
  end

end
