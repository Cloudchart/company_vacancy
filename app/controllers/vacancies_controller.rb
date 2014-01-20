class VacanciesController < ApplicationController
  before_action :set_vacancy, only: [:show, :edit, :update, :destroy]
  before_action :set_company, only: [:new, :create]

  # GET /vacancies
  def index
    @vacancies = Vacancy.all
  end

  # GET /vacancies/1
  def show
  end

  # GET /vacancies/new
  def new
    @vacancy = Vacancy.new
  end

  # GET /vacancies/1/edit
  def edit
  end

  # POST /vacancies
  def create
    @vacancy = Vacancy.new(vacancy_params)
    @vacancy.company = @company

    if @vacancy.save
      redirect_to @vacancy, notice: t('messages.created', name: t('lexicon.vacancy'))
    else
      render :new
    end
  end

  # PATCH/PUT /vacancies/1
  def update
    if @vacancy.update(vacancy_params)
      redirect_to @vacancy, notice: t('messages.updated', name: t('lexicon.vacancy'))
    else
      render :edit
    end
  end

  # DELETE /vacancies/1
  def destroy
    company = @vacancy.company
    @vacancy.destroy
    redirect_to company_vacancies_url(company), notice: t('messages.destroyed', name: t('lexicon.vacancy'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vacancy
      @vacancy = Vacancy.find(params[:id])
    end

    def set_company
      @company = Company.find(params[:company_id])
    end

    # Only allow a trusted parameter "white list" through.
    def vacancy_params
      params.require(:vacancy).permit(:name, :description, :salary, :location)
    end
end
