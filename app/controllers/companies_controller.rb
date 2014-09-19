class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy, :verify_site_url, :download_verification_file]
  before_action :set_collection, only: [:index, :search]

  # TODO: update
  # before_action :display_invite_notice, only: :show

  authorize_resource
  
  # GET /companies
  def index
  end

  def search
    respond_to do |format|
      format.html { render :index }
      format.js
    end
  end

  # GET /companies/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  def new
    @company = Company.new(name: 'Default Company')
    @company.access_rights.create(user: current_user, role: :owner)
    @company.should_build_objects!
    @company.save!
    
    redirect_to @company
  end
  
  # POST /companies/1/logo
  def upload_logo
    logo = Logo.new image: params[:image]
    @company = Company.find(params[:id])
    @company.logo = logo

    respond_to do |format|
      format.json { render nothing: true }
      format.js
    end
  end
  
  # GET /companies/1/edit
  def edit
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      Activity.track_activity(current_user, params[:action], @company)

      update_site_url_verification(@company) if company_params[:site_url]

      respond_to do |format|
        format.html { redirect_to @company }
        format.json { render json: @company, serializer: Editor::CompanySerializer }
      end

    else

      respond_to do |format|
        format.json { render json: :nok, status: 412 }
      end

    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to cloud_profile.companies_path, notice: t('messages.destroyed', name: t('lexicon.company'))
  end

  def verify_site_url
    uri = URI.parse(@company.formatted_site_url)
    uri.path = "/#{@company.humanized_id}.txt"
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      @company.tokens.where(name: :site_url_verification).destroy_all
      File.delete(File.join(Rails.root, 'tmp', 'verifications', "#{@company.humanized_id}.txt"))

      respond_to do |format|
        format.html { redirect_to @company, notice: 'Site URL verified' }
        format.json { render json: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to @company, alert: 'Site URL verification failed.' }
        format.json { render json: :fail }
      end
    end

  end

  def download_verification_file
    file_path = File.join(Rails.root, 'tmp', 'verifications', "#{@company.humanized_id}.txt")
    if File.exists?(file_path)
      send_file(file_path)
    else
      redirect_to :back, alert: 'Error. We did not find this file.'
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
    @company = Company.find(params[:id])
  end

  def set_collection
    @companies = Company.search(params)
  end

  # legacy
  # def display_invite_notice
  #   if token = @company.invite_tokens.select { |token| token.data[:user_id] == current_user.id }.first
  #     flash.now[:notice] = "You are invited to join this company. <a href='#{company_invite_path(token)}'>Please confirm</a>.".html_safe
  #   end
  # end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(
      :name,
      :site_url,
      :country, 
      :industry, 
      :industry_ids, 
      :description, 
      :established_on,
      :is_listed, 
      :logotype, 
      :remove_logotype, 
      :slug,
      sections_attributes: [Company::Sections.map(&:downcase)]
    )
  end

end
