class CompaniesController < ApplicationController
  include FollowableController

  before_action :set_company, only: [
    :update,
    :destroy,
    :verify_site_url,
    :download_verification_file,
    :finance,
    :settings
  ]
  before_action :set_collection, only: [:index, :search]

  authorize_resource
  
  # GET /companies
  def index
    authorize! :list, :companies
  end

  # POST /companies/search
  def search
    respond_to do |format|
      format.html { render :index }
      format.js
    end
  end

  # GET /companies/1
  def show
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
    @company = find_company(relation)

    respond_to do |format|
      format.html { pagescript_params(id: @company.uuid) }
      format.json { 
        @tags = Tag.order(:name).all
      }
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

  # GET /companies/1/finance
  def finance
  end

  # GET /companies/1/settings
  def settings
    pagescript_params(id: @company.uuid)
  end

  # GET /companies/1/access_rights
  def access_rights
    @company = find_company(Company.includes(:roles, users: :emails))

    respond_to do |format|
      format.html {
        pagescript_params(id: @company.uuid)
      }
      format.json {
        companies = current_user.companies
          .includes(:people, users: :emails)
          .where(roles: { value: ['owner', 'editor', 'trusted_reader'] })

        @invitable_contacts = %w[users people].inject({}) do |memo, association|
          companies.each do |company|
            company.send(association).each do |object|
              unless object.email.blank?
                memo[object.email] ||= []
                unless memo[object.email].include?(object.full_name)
                  memo[object.email].push(object.full_name)
                end
              end              
            end
          end

          memo
        end
      }
    end
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
    @company = find_company(Company.includes(:roles))
  end

  def find_company(relation)
    relation.find_by(slug: params[:id]) || relation.find(params[:id])
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
      :is_name_in_logo, 
      :slug,
      :tag_names
    )
  end

end
