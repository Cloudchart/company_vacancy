require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController

    def new
      redirect_to main_app.root_path if user_authenticated?
    end

    def create
      authentication = Authentication.new(email: params[:email], password: params[:password])
      
      if authentication.valid?
        warden.set_user(authentication.user, scope: :user)
        cookies.signed[:user_id] = { value: authentication.user.id, expires: 2.weeks.from_now }

        respond_to do |format|
          format.json { render json: { previous_path: previous_path } }
        end
      else
        respond_to do |format|
          format.json { render json: { errors: authentication.errors }, status: 412 }
        end
      end
    end
    
    def destroy
      warden.logout(:user)
      cookies.delete :user_id
      redirect_to main_app.root_path
    end
    
  end
end
