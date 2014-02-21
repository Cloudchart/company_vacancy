class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  authorize_resource

  # GET /companies
  def index
    @companies = Company.all
  end

  # GET /companies/1
  def show
    @blocks = @company.blocks
    @vacancies = @company.vacancies
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  def create
    @company = Company.new(company_params)
    person = @company.people.build(name: current_user.name, email: current_user.email, phone: current_user.phone)
    person.user = current_user

    Rails.logger.info("#{'*'*1000} #{@company.inspect}")
    if @company.save
      redirect_to @company, notice: t('messages.created', name: t('lexicon.company'))
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      redirect_to @company, notice: t('messages.updated', name: t('lexicon.company'))
    else
      render action: 'edit'
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to companies_url, notice: t('messages.destroyed', name: t('lexicon.company'))
  end

private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.includes(:logo, blocks: { block_identities: :identity }).find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(:name, :description, logo_attributes: :image)
  end

end
