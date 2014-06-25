class VacanciesController < ApplicationController
  before_action :set_vacancy, only: [:show, :update, :destroy, :change_status]
  before_action :set_company, only: [:index, :new, :create]
  before_action :build_vacancy, only: :new
  before_action :build_vacancy_with_params, only: :create
  before_action :authorize_company, only: :index

  authorize_resource except: :index

  impressionist actions: [:show], unique: [:ip_address]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to (@vacancy ? company_vacancies_path(@vacancy.company) : companies_path), alert: exception.message
  end

  # GET /vacancies
  def index
    @vacancies = @company.vacancies.order(:name)
  end

  # GET /vacancies/1
  def show
    pagescript_params(
      can_update_vacancy: can?(:update, @vacancy),
      can_update_company: can?(:update, @vacancy.company)
    )
  end

  # GET /vacancies/new
  def new
  end

  # POST /vacancies
  def create
    @vacancy.should_build_objects!
    @vacancy.author = current_user

    if @vacancy.save
      Activity.track_activity(current_user, 'open', @vacancy)
      redirect_to @vacancy, notice: t('messages.created', name: t('lexicon.vacancy'))
    else
      render :new
    end
  end

  # PATCH/PUT /vacancies/1
  def update
    if @vacancy.update(vacancy_params)
      Activity.track_activity(current_user, 'edit', @vacancy)
      redirect_to @vacancy, notice: t('messages.updated', name: t('lexicon.vacancy'))
    else
      render :show
    end
  end

  # DELETE /vacancies/1
  def destroy
    company = @vacancy.company
    @vacancy.destroy
    redirect_to company_vacancies_url(company), notice: t('messages.destroyed', name: t('lexicon.vacancy'))
  end

  def change_status
    # TODO: add status check
    @vacancy.update(status: params[:status])

    if params[:status] == 'opened'
      @vacancy.settings.publish_on = Date.today
      @vacancy.save
    end

    redirect_to :back, notice: 'Status has been updated'
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
    params.require(:vacancy).permit(:name, :description, :salary, :location, settings: VacancySetting.attributes.symbolize_keys.keys)
  end

  def build_vacancy
    @vacancy = @company.vacancies.build
  end

  def build_vacancy_with_params
    @vacancy = @company.vacancies.build(vacancy_params)
  end

  def authorize_company
    authorize! :access_vacancies, @company
  end 

end
