class VacancyResponsesController < ApplicationController
  before_action :set_vacancy_response, only: [:show, :update, :destroy]
  before_action :set_vacancy, only: [:index, :new, :show, :invite_person, :kick_person]
  before_action :set_person, only: [:invite_person, :kick_person]
  before_action :authorize_readers, only: [:index, :show]
  before_action :authorize_admins, only: [:invite_person, :kick_person]

  respond_to :html, except: [:invite_person, :kick_person]
  respond_to :js, only: [:invite_person, :kick_person]

  authorize_resource except: [:index, :show, :invite_person, :kick_person]

  def index
    pagescript_params(company_id: @vacancy.company_id, vacancy_id: @vacancy.id)
  end

  def show
    @comments = @vacancy_response.comments.includes(:user).order(updated_at: :desc)
    @comment = @vacancy_response.comments.build
  end

  def new
    @vacancy_response = @vacancy.responses.build
  end

  def create
    @vacancy_response = VacancyResponse.new(vacancy_response_params)
    @vacancy_response.user = current_user
    @vacancy = @vacancy_response.vacancy

    if @vacancy_response.save
      Activity.track_activity(current_user, 'respond', @vacancy)
      UserMailer.send_vacancy_response(@vacancy, @vacancy.company.owner.emails.first).deliver
      redirect_to @vacancy, notice: t('messages.vacancies.respond.success')
    else
      render :new
    end
  end

  def invite_person
    unless @vacancy.reviewers.include?(@person)
      @vacancy.reviewers << @person
      @success = true
    end
  end

  def kick_person
    @vacancy.reviewers.delete(@person)
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_vacancy_response
    @vacancy_response = VacancyResponse.find(params[:id])
  end

  def set_vacancy
    @vacancy = Vacancy.find(params[:vacancy_id])
  end

  def set_person
    @person = Person.find(params[:person_id])
  end

  # Only allow a trusted parameter "white list" through.
  def vacancy_response_params
    params.require(:vacancy_response).permit(:content, :vacancy_id)
  end

  def authorize_admins
    authorize! :invite_and_kick_people, @vacancy
  end

  def authorize_readers
    authorize! :access_vacancy_responses, @vacancy
  end

end
