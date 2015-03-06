require_dependency "cloud_profile/application_controller"

module CloudProfile
  class PasswordsController < ApplicationController

    # Send password reset link
    #
    def create
      email = Email.find_by(address: params[:email])
      
      if email.present?
        token = Token.create(name: :password, data: { address: email.address })
        ProfileMailer.password_reset(token).deliver
      end
      
      respond_to do |format|
        format.json { render json: { state: :ok } }
      end
    end
    
    
    # Request reset password
    #
    def reset
      token = Token.where(name: :password).find(params[:token]) rescue nil
    
      pagescript_params(token: token.to_param)
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
        format.json { render json: { status: :ok, previous_path: previous_path } }
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

  end
end
