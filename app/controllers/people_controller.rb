class PeopleController < ApplicationController
  include TokenableController

  before_action :set_person, only: [:show, :edit, :update, :destroy, :send_invite_to_user]
  before_action :set_company, only: [:index, :new, :create, :search]
  before_action :build_person, only: :new
  before_action :build_person_with_params, only: :create
  before_action :authorize_company, only: :index

  authorize_resource except: :index

  # GET /people
  def index
    @people = @company.people
    pagescript_params(company_id: @company.id)
  end

  def search
    company_people = @company.people.search(params).results

    if params[:vacancy_id]
      vacancy = Vacancy.find(params[:vacancy_id])
      vacancy_reviewers_ids = vacancy.reviewers.map(&:id)
      company_people = company_people.select { |person| person.user_id.present? && !vacancy_reviewers_ids.include?(person.id) }
      company_people_friends = []
    else
      company_people_friends = Friend.related_to_company(@company.id).search(params).results
    end

    @people = company_people + company_people_friends

    respond_to do |format|
      format.js
    end
  end

  # GET /people/1
  def show
  end

  # GET /people/new
  def new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    if @person.save
      redirect_to @person, notice: t('messages.created', name: t('lexicon.person'))
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /people/1
  def update
    if @person.update(person_params)
      redirect_to @person, notice: t('messages.updated', name: t('lexicon.person'))
    else
      render action: 'edit'
    end
  end

  # DELETE /people/1
  def destroy
    company = @person.company
    @person.destroy
    redirect_to company_people_url(company), notice: t('messages.destroyed', name: t('lexicon.person'))
  end

  # POST /people/1/send_invite_to_user
  def send_invite_to_user
    return redirect_to person_path(@person), alert: t('messages.company_invite.email_blank') if params[:email].blank?
    email = CloudProfile::Email.find_by(address: params[:email])
 
    if email
      # check if user already has person in this company
      if email.user.people.map(&:company_id).include?(@person.company_id)
        return redirect_to person_path(@person), alert: t('messages.company_invite.user_has_already_been_associated')
      else
        create_company_invite_token_and_send_email(@person.id, email)
      end
    else
      create_company_invite_token_and_send_email(@person.id)
    end

    redirect_to person_path(@person), notice: t('messages.company_invite.email_sent')
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  # Only allow a trusted parameter "white list" through.
  def person_params
    params.require(:person).permit(:first_name, :last_name, :email, :phone, :occupation)
  end

  def build_person
    @person = @company.people.build
  end

  def build_person_with_params
    @person = @company.people.build(person_params)
  end

  def authorize_company
    authorize! :access_people, @company
  end

  def create_company_invite_token_and_send_email(person_id, email=nil)
    clean_session_and_destroy_token(Token.find_by(data: person_id.to_yaml))
    token = Token.new(name: :company_invite, data: person_id)
    token.owner = email.try(:user)
    token.save!
    email = params[:email] unless email
    UserMailer.send_company_invite(@person.company, email, token).deliver
  end

end
