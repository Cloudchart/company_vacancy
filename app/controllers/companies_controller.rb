class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
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
      format.json { render json: @company, serializer: Editor::CompanySerializer }
    end
  end

  # GET /companies/new
  def new
    @company = Company.new(name: 'Default Company')
    @company.associate_with_person(current_user)
    @company.should_build_objects!
    @company.save!
    Activity.track_activity(current_user, :create, @company)
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
    @company.update!(company_params)
    Activity.track_activity(current_user, params[:action], @company)
    
    respond_to do |format|
      format.html { redirect_to @company }
      format.json { render json: @company, serializer: Editor::CompanySerializer }
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
    params.require(:company).permit(:name, :country, :industry, :industry_ids, :description, :is_listed, :logotype, :remove_logotype, sections_attributes: [Company::Sections.map(&:downcase)])
  end
  
end
