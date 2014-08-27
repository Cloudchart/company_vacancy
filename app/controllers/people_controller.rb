class PeopleController < ApplicationController

  before_action :set_person, only: [:show, :edit, :update, :destroy, :send_invite_to_user, :make_owner]
  before_action :set_company, only: [:index, :new, :create, :search]
  before_action :build_person, only: :new
  before_action :build_person_with_params, only: :create
  before_action :authorize_company, only: :index

  authorize_resource except: :index

  # GET /people
  def index
    @people = @company.people.includes(:user)

    pagescript_params(company_id: @company.id)
    
    respond_to do |format|
      format.html
      format.json { render json: @people, root: false }
    end
  end

  def search
    company_people = Person.search(params).results
    company_people_friends = Friend.search(params).results

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
    return redirect_to :back, alert: t('messages.company_invite.email_blank') if params[:email].blank?
    email = CloudProfile::Email.find_by(address: params[:email])
 
    if email
      # check if user already has person in this company
      if email.user.people.map(&:company_id).include?(@person.company_id)
        return redirect_to :back, alert: t('messages.company_invite.user_has_already_been_associated')
      else
        create_company_invite_token_and_send_email(@person.id, email)
      end
    else
      create_company_invite_token_and_send_email(@person.id)
    end

    redirect_to :back, notice: t('messages.company_invite.email_sent')
  end

  def make_owner
    if @person.user
      @person.update(is_company_owner: true)

      respond_to do |format|
        format.json { render json: { owners: @person.company.owners } }
      end

    elsif @person.email.present?
      email = CloudProfile::Email.find_by(address: @person.email)

      if email && email.user.people.map(&:company_id).include?(@person.company_id)
        respond_to do |format|
          format.json { render json: { message: t('messages.company_invite.user_has_already_been_associated') } }
        end
      else
        create_company_invite_token_and_send_email(@person, email)
        invited_person_ids = Token.where(name: :company_invite, owner: @person.company).map { |token| token.data[:person_id] }

        respond_to do |format|
          format.json { render json: { invites: Person.find(invited_person_ids) } }
        end
      end

    else
      # render input
    end
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

  def create_company_invite_token_and_send_email(person, email)
    token = Token.where(name: :company_invite, owner: person.company).select { |token| token.data[:person_id] == person.id }.first

    unless token
      token = Token.create!(name: :company_invite, data: { user_id: current_user.id, person_id: person.id }, owner: person.company)
    end

    UserMailer.company_invite(email || params[:email], token).deliver
  end

end
