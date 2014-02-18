class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy, :send_invite_to_user]
  before_action :set_company, only: [:index, :new, :create]

  # GET /people
  def index
    @people = Person.all
  end

  # GET /people/1
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    @person = Person.new(person_params)
    @person.company = @company

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
    user = User.find_by(email: params[:email])
 
    if user
      # check if user already has person in this company
      if user.people.map(&:company_id).include?(@person.company_id)
        return redirect_to person_path(@person), alert: t('messages.company_invite.user_has_already_been_associated')
      else
        Token.find_by(data: @person.id.to_yaml).try(:destroy)
        token = user.create_company_invite_token(@person.id)
        UserMailer.send_company_invite(@person.company, user, token).deliver
      end
    else
      # TODO: create unassociated token and send email
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
    params.require(:person).permit(:name, :email, :phone, :occupation)
  end

end
