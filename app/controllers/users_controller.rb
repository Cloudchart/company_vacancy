class UsersController < ApplicationController
  include TokenableController

  before_action :set_user, only: [:show, :edit, :update, :destroy, :associate_with_person]

  authorize_resource

  # GET /users/1
  def show
    @versions = PaperTrail::Version.where(whodunnit: @user.id)
  end

  # get /sign-up
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      create_confirmation_token_and_send_email(@user)
      redirect_to root_path, notice: t('messages.email_sent', action: t('actions.confirm_your_account'))
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)

      if @user.email == params[:user][:email]
        notice = t('messages.updated', name: t('lexicon.user'))
      else
        notice = t('messages.email_sent', action: t('actions.change_email'))
        create_reconfirmation_token_and_send_email(@user)
      end

      redirect_to @user, notice: notice
    else
      render :edit
    end
  end

  def activate
    token = Token.find(params[:token_id]) rescue nil

    if token
      token.destroy

      redirect_to login_path, notice: t('messages.successful_action', 
        thing: t('lexicon.account').mb_chars.downcase.to_s,
        action: t('actions.activated')
      )
    else
      redirect_to root_path, alert: t('messages.tokens.not_found', action: t('actions.activation'))
    end
  end

  def reactivate
    token = Token.find(params[:token_id]) rescue nil

    # logout, update user email and destroy all reconfirmation tokens with identical email
    if token
      warden.logout(:user)
      token.owner.update_attribute(:email, token.data)
      Token.where(name: :reconfirmation, data: token.data.to_yaml).destroy_all

      redirect_to login_path, notice: t('messages.successful_action',
        thing: t('lexicon.email').mb_chars.downcase.to_s,
        action: t('actions.changed')
      )
    else
      redirect_to root_path, alert: t('messages.tokens.not_found', action: t('actions.email_change'))
    end
  end

  def associate_with_person
    token = Token.find(params[:token_id]) rescue nil

    if token
      person = Person.find(token.data)

      if @user.people.map(&:company_id).include?(person.company_id)
        return redirect_to company_invite_path(token), alert: t('messages.company_invite.you_are_already_associated', name: person.company.name)
      end

      @user.people << person
      @user.save!
      clean_session_and_destroy_token(token)

      redirect_to company_path(person.company), notice: t('messages.invitation_completed')
    else
      redirect_to root_path, alert: t('messages.tokens.not_found', action: t('actions.company_invite'))
    end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone, avatar_attributes: :image)
  end

  def create_confirmation_token_and_send_email(user)
    user.tokens.create(name: :confirmation)
    PassportMailer.confirmation_instructions(user).deliver
  end

  def create_reconfirmation_token_and_send_email(user)
    user.tokens.where(name: :reconfirmation).destroy_all
    user.tokens.create(name: :reconfirmation, data: params[:user][:email])
    PassportMailer.reconfirmation_instructions(user).deliver
  end

end
