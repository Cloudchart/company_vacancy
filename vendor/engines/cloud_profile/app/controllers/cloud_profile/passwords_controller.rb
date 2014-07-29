require_dependency "cloud_profile/application_controller"

module CloudProfile
  class PasswordsController < ApplicationController

    before_action :require_authenticated_user!, only: [:show, :update]
    before_action :require_unauthenticated_user!, only: [:new, :create]
    
    
    # Send password reset link
    #
    def create
      email = Email.find_by(address: params[:email])
      
      if email.present?
        token = Token.create(name: 'password-reset', data: { address: email.address })
        ProfileMailer.password_reset(token).deliver
      end
      
      respond_to do |format|
        format.json { render json: { state: :ok } }
      end
    end
    
    
    # Request reset password
    #
    def reset
      token = Token.find(params[:token]) rescue nil
      redirect_to main_app.root_path(password_reset: token)
    end
    
    
    # Reset password
    #
    def complete_reset
      token = Token.find(params[:token])
      user  = User.find_by_email(token.data[:address])
      
      user.password_digest = nil
      user.update! params.require(:user).permit(:password, :password_confirmation)
      
      token.destroy
      
      warden.set_user(user, scope: :user)
      
      respond_to do |format|
        format.json { render json: { status: :ok } }
      end
      
    rescue ActiveRecord::RecordNotFound

      respond_to do |format|
        format.json { render json: :nok, status: 403 }
      end

    rescue ActiveRecord::RecordInvalid

      respond_to do |format|
        format.json { render json: user.errors, status: 412 }
      end

    end
    

    # Reset password
    #
    #def reset_complete
    #  @token  = Token.find(params[:token])
    #  @email  = Email.find_by(address: @token.data[:address])
    #  @user   = @email.user
    #  
    #  @user.password_digest = nil
    #  @user.update! params.require(:user).permit([:password, :password_confirmation])
    #  
    #  @token.destroy
    #  
    #  redirect_to login_path(email: @email.address)
    #
    #rescue ActiveRecord::RecordInvalid
    #  render :reset
    #end
    
    
    # Update current password
    #
    def update
      unless current_user.authenticate(params[:current_password])
        current_user.errors.add(:current_password, :invalid)
        raise ActiveRecord::RecordInvalid.new(current_user)
      end

      current_user.password_digest = nil
      current_user.update!(password: params[:password], password_confirmation: params[:password_confirmation])

      redirect_to :settings

    rescue ActiveRecord::RecordInvalid
      render :show
    end
    

  end
end
