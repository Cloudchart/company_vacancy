class PasswordResetsController < ApplicationController
  before_action :set_token, only: [:edit, :update]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    user.send_password_reset if user
    redirect_to root_path, notice: t('messages.reset_password_email')
  end

  def edit
    if @token
      @user = @token.tokenable
    else
      redirect_to root_path, alert: t('messages.tokens.password_reset_not_found')
    end

  end

  def update
    @user = @token.tokenable

    if @user.update_attributes(user_params)
      redirect_to login_path, notice: t('messages.password_has_been_reset')
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

end
