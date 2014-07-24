class VacancyResponsesController < ApplicationController
  before_action :set_vacancy, except: [:show, :destroy, :vote, :change_status]
  before_action :set_vacancy_response, only: [:show, :destroy, :vote, :change_status]
  before_action :authorize_vacancy, only: :index

  authorize_resource except: :index

  def index
    pagescript_params(
      collection_url: vacancy_responses_path(@vacancy),
      reviewers_url: update_reviewers_vacancy_path(@vacancy),
      reviewers: @vacancy.reviewers
    )

    @company_people = @vacancy.company.people.select do |person| 
      person.user_id.present? &&
      !@vacancy.reviewers.map(&:id).include?(person.id) &&
      person.user_id != current_user.id &&
      person.user_id != @vacancy.author_id
    end

    respond_to do |format|
      format.html
      format.json { render json: @company_people, root: false }
    end
  end

  def show
    @comments = @vacancy_response.comments.includes(:user).order(updated_at: :desc)
    @comment = @vacancy_response.comments.build
    @current_vote = @vacancy_response.votes.find_by(source: current_user).try(:value)
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

  def destroy
    @vacancy_response.destroy
  end

  def vote
    vote = Vote.find_by(source: current_user, destination: @vacancy_response)

    if vote
      vote.update(value: params[:vote])
    else
      vote = Vote.create(source: current_user, destination: @vacancy_response, value: params[:vote])
    end

    @current_vote = vote.value
  end

  def change_status
    status = params[:status]

    if status.present? && %[in_review accepted declined].include?(status)
      @vacancy_response.update(status: status)
    end

    redirect_to :back, notice: 'Status has been updated'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_vacancy_response
    @vacancy_response = VacancyResponse.includes(:vacancy, :votes).find(params[:id])
  end

  def set_vacancy
    @vacancy = Vacancy.includes(responses: [:user, :votes]).find(params[:vacancy_id])
  end

  # Only allow a trusted parameter "white list" through.
  def vacancy_response_params
    params.require(:vacancy_response).permit(:content, :vacancy_id)
  end

  def authorize_vacancy
    authorize! :access_vacancy_responses, @vacancy
  end

end
