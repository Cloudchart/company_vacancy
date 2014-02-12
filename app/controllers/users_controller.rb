class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params_on_create)

    if @user.save
      create_confirmation_token_and_send_email(@user)
      redirect_to root_path, notice: t('messages.email_sent', action: t('actions.confirm_your_account'))
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params_on_update)

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

  # GET user/1/activate
  def activate
    token = Token.find_by(uuid: params[:id])

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

  # GET user/1/reactivate
  def reactivate
    token = Token.find_by(uuid: params[:id])

    # logout, update user email and destroy all reconfirmation tokens with identical email
    if token
      warden.logout(:user)
      token.tokenable.update_attribute(:email, token.data)
      Token.where(name: :reconfirmation, data: token.data.to_yaml).destroy_all

      redirect_to login_path, notice: t('messages.successful_action',
        thing: t('lexicon.email').mb_chars.downcase.to_s,
        action: t('actions.changed')
      )
    else
      redirect_to root_path, alert: t('messages.tokens.not_found', action: t('actions.email_change'))
    end

  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params_on_create
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def user_params_on_update
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone, avatar_attributes: :image)
    end

    def create_confirmation_token_and_send_email(user)
      user.create_confirmation_token
      PassportMailer.confirmation_instructions(user).deliver
    end

    def create_reconfirmation_token_and_send_email(user)
      user.destroy_garbage_and_create_reconfirmation_token(params[:user][:email])
      PassportMailer.reconfirmation_instructions(user).deliver
    end

end
