class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy, :verify_url]

  # -- https://github.com/rails/rails/issues/9703
  #
  skip_before_action :require_authenticated_user!
  before_action :require_authenticated_user!, except: :show
  before_action :require_authenticated_user!, only: :show, unless: -> { @company.is_public? }
  # --

  before_action :set_collection, only: [:index, :search]

  authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to (@company || companies_path), alert: exception.message
  end

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
    @company.associate_with_person(current_user)
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

      update_url_verification(@company) if company_params[:url]

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

  def verify_url
    token = Token.find_by_rfc1751(params[:token])
    url = @company.url
    url = 'http://' + @company.url unless @company.url.match(/http:\/\/|https:\/\//)
    uri = URI.parse(url)
    uri.path = '/cloudchart_company_url_verification.txt'
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      token = Token.find_by_rfc1751(response.body)

      if token
        @company.tokens.where(name: :url_verification).destroy_all
        redirect_to @company, notice: 'Site URL verified'
      else
        redirect_to @company, alert: 'Site URL verification failed. Code: TNF.'
      end
      
    else
      redirect_to @company, alert: 'Site URL verification failed. Code: RNF.'
    end
  end

private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  def set_collection
    @companies = Company.search(params)
  end

  def set_person
    @person = (current_user.people & @company.people).first
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(:name, :short_name, :url, :country, :industry, :industry_ids, :description, :is_listed, :logotype, :remove_logotype, sections_attributes: [Company::Sections.map(&:downcase)])
  end

  # generate tmp file here
  def update_url_verification(company)
    if company_params[:url] == ''
      company.tokens.where(name: :url_verification).destroy_all
    else
      token = company.tokens.find_by(name: :url_verification)

      unless token
        token = company.tokens.create!(name: :url_verification, data: { user_id: current_user.id })
      end

      UserMailer.company_url_verification(token).deliver
    end

  end
  
end
