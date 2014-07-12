class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :destroy, :subscribe, :unsubscribe]
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
    pagescript_params(can_update_company: can?(:update, @company))
    respond_to do |format|
      format.html
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  def new
    @company = Company.find_or_create_placeholder_for(current_user)
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
    @company          = Company.find(params[:id])
    @company.is_empty = false
    
    @company.update! company_params

    Activity.track_activity(current_user, params[:action], @company)
    
    respond_to do |format|
      format.json { render json: @company.reload, serializer: Editor::CompanySerializer }
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to cloud_profile.companies_path, notice: t('messages.destroyed', name: t('lexicon.company'))
  end

private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.includes(:logo, blocks: { block_identities: :identity }).find(params[:id])
  end

  def set_collection
    # @companies = Company.includes(:logo, :industries, :people, :vacancies).where(is_empty: false).order(:name)
    @companies = Company.search(params)
  end

  def set_person
    @person = (current_user.people & @company.people).first
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(:name, :country, :industry_ids, :description, sections_attributes: [Company::Sections.map(&:downcase)], logo_attributes: [:id, :image, :_destroy])
  end
  
end
