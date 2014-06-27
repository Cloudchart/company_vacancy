class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy, :subscribe, :unsubscribe]
  before_action :set_collection, only: [:index, :search]

  authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to (@company || companies_path), alert: exception.message
  end

  # GET /companies
  def index
  end

  def search
    @companies = @companies.find(Company.search(params).results.map(&:to_param))

    if params[:country].present?
      @companies = @companies.select { |company| company.country == params[:country] }
    end

    if params[:industry_id].present?
      @companies = @companies.select do |company| 
        company.industry.id == params[:industry_id] || company.industry.parent_id == params[:industry_id]
      end
    end

    # render :index
    respond_to do |format|
      format.js
    end
  end

  # GET /companies/1
  def show
    pagescript_params(can_update_company: can?(:update, @company))
  end

  # GET /companies/new
  def new
    @company = Company.find_or_create_placeholder_for(current_user)
    # redirect_to edit_company_path(@company)
  end
  
  
  # POST /companies/1/logo
  def upload_logo
    logo = Logo.new image: params[:image]
    @company = Company.find(params[:id])
    @company.logo = logo
    respond_to do |format|
      format.js
    end
  end
  
  

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # def create
  #  @company = Company.new(company_params)
  #  @company.associate_with_person(current_user)
  #  @company.should_build_objects!

  #  @company.save!
  #  Activity.track_activity(current_user, params[:action], @company)
  #  redirect_to @company, notice: t('messages.created', name: t('lexicon.company'))
  # rescue ActiveRecord::RecordInvalid
  #  render :new
  # end

  # PATCH/PUT /companies/1
  def update
    @company.is_empty = false
    if @company.update(company_params)
      Activity.track_activity(current_user, params[:action], @company)
      respond_to do |format|
        format.html { redirect_to @company, notice: t('messages.updated', name: t('lexicon.company')) }
        format.js
      end
    else
      render :edit
    end
  end

  # DELETE /companies/1
  def destroy
    company = @company
    @company.destroy
    Activity.track_activity(current_user, params[:action], company)
    redirect_to companies_url, notice: t('messages.destroyed', name: t('lexicon.company'))
  end

private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.includes(:logo, blocks: { block_identities: :identity }).find(params[:id])
  end

  def set_collection
    @companies = Company.where(is_empty: false).includes(:logo, :industries, :people).order(:name)
  end

  def set_person
    @person = (current_user.people & @company.people).first
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(:name, :country, :industry_ids, :description, logo_attributes: :image)
  end

end
