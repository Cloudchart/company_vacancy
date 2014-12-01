class CompaniesController < ApplicationController
  include FollowableController

  before_action :set_company, only: [
    :show,
    :edit,
    :update,
    :destroy,
    :verify_site_url,
    :download_verification_file,
    :finance,
    :settings,
    :access_rights
  ]
  before_action :set_collection, only: [:index, :search]

  authorize_resource
  
  # GET /companies
  def index
    authorize! :list, :companies
  end

  def search
    respond_to do |format|
      format.html { render :index }
      format.js
    end
  end

  # GET /companies/1
  def show
    pagescript_params(id: @company.uuid)
    @tags = Tag.order(:name).all

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /companies/new
  def new
    @company = Company.new
    @company.roles.build(user: current_user, value: :owner)
    @company.should_build_objects!
    @company.save!
    
    redirect_to @company
  end
  
  # GET /companies/1/edit
  def edit
  end

  # PATCH/PUT /companies/1
  def update
    @company.update!(company_params)
    
    Activity.track_activity(current_user, params[:action], @company)
    
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
    redirect_to cloud_profile.companies_path, notice: t('messages.destroyed', name: t('lexicon.company'))
  end

  def finance
  end

  def settings
    pagescript_params(id: @company.uuid)
  end

  def access_rights
    # TODO: includes :emails to current_user
    current_user_email = current_user.email

    companies = current_user.companies
      .includes(:people, users: :emails)
      .where(roles: { value: ['owner', 'editor', 'trusted_reader'] })

    invitable_contacts = companies.inject([]) do |memo, company|
      %w[people users].each do |association|
        company.send(association).each do |object|
          memo.push({ uuid: object.uuid, full_name: object.full_name, email: object.email })
        end
      end

      memo
    end

    @invitable_contacts = invitable_contacts
      .reject { |contact| contact[:email].blank? || contact[:email] == current_user_email }
      .uniq { |contact| contact[:email] }

    Rails.logger.info("\n #{'*'*25} #{@invitable_contacts} #{'*'*25} \n")

    # TODO: create jbuilder template
    respond_to do |format|
      format.html
      format.json do
        render json: {
          users:  ActiveModel::ArraySerializer.new(@company.users.includes(:emails)),
          roles:  ActiveModel::ArraySerializer.new(@company.roles),
        }
      end
    end
  end

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
    if company_params[:site_url] == ''
      company.tokens.where(name: :site_url_verification).destroy_all
    else
      token = Token.find_or_create_token_by!(name: :site_url_verification, owner: company, data: { user_id: current_user.id })
      dir_location = File.join(Rails.root, 'tmp', 'verifications')
      file_location = File.join(dir_location, "#{company.humanized_id}.txt")
      unless File.exists?(file_location)
        FileUtils.mkdir_p(dir_location)
        File.open(file_location, 'w') { |f| f.write('Good luck using CloudChart!') }
      end

      UserMailer.company_url_verification(token).deliver
    end
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    relation = Company.includes(
      :people,
      :vacancies,
      :pictures,
      :paragraphs,
      :roles,
      :tokens,
      users: :emails,
      blocks: :block_identities
    )

    @company = relation.find_by(slug: params[:id]) || relation.find(params[:id])
  end

  def set_collection
    @companies = Company.search(params)
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
      :slug,
      :tag_names
    )
  end

end
