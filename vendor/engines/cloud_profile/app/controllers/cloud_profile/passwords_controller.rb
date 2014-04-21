require_dependency "cloud_profile/application_controller"

module CloudProfile
  class PasswordsController < ApplicationController

    before_action :require_authenticated_user!, only: [:show, :update]
    before_action :require_unauthenticated_user!, only: [:new, :create]
    
    
    # Send password reset link
    #
    def create
      email = Email.find_by!(address: params[:address])
      @token = Token.create name: 'password-reset', data: { address: email.address }
      ProfileMailer.password_reset(@token).deliver
      redirect_to :login
    rescue ActiveRecord::RecordNotFound
      @email = Email.new
      @email.errors.add(:address, :invalid)
      render :new
    end
    

    # Reset password form
    #
    def reset
      @token = Token.find(params[:token])
    end
    

    # Reset password
    #
    def reset_complete
      @token  = Token.find(params[:token])
      @email  = Email.find_by(address: @token.data[:address])
      @user   = @email.user
      
      @user.password_digest = nil
      @user.update! params.require(:user).permit([:password, :password_confirmation])
      
      @token.destroy
      
      redirect_to login_path(email: @email.address)

    rescue ActiveRecord::RecordInvalid
      render :reset
    end
    
    
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
