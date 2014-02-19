class PasswordResetsController < ApplicationController
  before_action :set_token, only: [:edit, :update]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    create_recover_token_and_send_email(user) if user && user.tokens.find_by(name: :confirmation).nil?
    redirect_to root_path, notice: t('messages.email_sent', action: t('actions.reset_password'))
  end

  def edit
    if @token
      @user = @token.owner
    else
      redirect_to root_path, alert: t('messages.tokens.not_found', action: t('actions.password_reset'))
    end

  end

  def update
    @user = @token.owner

    if @user.update(user_params)
      redirect_to login_path, notice: t('messages.successful_action',
        thing: t('lexicon.password').mb_chars.downcase.to_s,
        action: t('actions.reset')
      )
      @token.destroy
    else
      render :edit
    end

  end

  private

    def set_token
      @token = Token.find_by(uuid: params[:id])
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def create_recover_token_and_send_email(user)
      user.tokens.where(name: :recover).destroy_all
      user.tokens.create(name: :recover)      
      PassportMailer.recover_instructions(user).deliver
    end

end
