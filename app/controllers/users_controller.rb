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
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path, notice: t('messages.confirmation_email')
    else
      render 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: t('messages.updated', name: 'User')
    else
      render action: 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to root_path, notice: t('messages.destroyed', name: 'User')
  end

  # GET user/1/activate
  def activate
    token = Token.find_by(uuid: params[:id])

    if token
      redirect_to login_path, notice: t('messages.activated')
      token.destroy
    else
      redirect_to root_path, alert: t('messages.tokens.confirmation_not_found')
    end

  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone, :avatar)
    end

end
