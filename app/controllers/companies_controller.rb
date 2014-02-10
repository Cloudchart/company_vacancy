class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :find_blockables, only: [:edit, :update]
  before_action :build_logo, only: [:edit, :update]

  # GET /companies
  def index
    @companies = Company.all
  end

  # GET /companies/1
  def show
    @blocks = @company.blocks
  end

  # GET /companies/new
  def new
    @company = Company.new
    @company.build_logo
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  def create
    @company = Company.new(company_params)
    @company.build_logo unless @company.logo.present?

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
      @company = Company.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def company_params
      params.require(:company).permit(:name, :description, logo_attributes: :image)
    end

    def find_blockables
      @blockables = @company.blocks.map(&:blockable)
    end

    def build_logo
      @company.build_logo unless @company.logo.present?
    end

end
