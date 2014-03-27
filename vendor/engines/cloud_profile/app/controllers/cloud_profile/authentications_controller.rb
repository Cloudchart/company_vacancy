require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController
    

    def new
      store_return_path unless return_path_stored?

      @email = Email.find_or_initialize_by(address: params[:email])
      if @email.valid?
        if @email.persisted?
          render :create and return
        else
          redirect_to register_path(email: @email.address) and return
        end
      end
    end
    

    def create
      email = Email.find_by(address: params[:email])
      if email.present? && email.active? && email.user.authenticate(params[:password])
        warden.set_user(email.user, scope: :user)
        redirect_to_stored_path_or_root and return
      end
    end
    

    def destroy
      warden.logout
      redirect_to_stored_path_or_root
    end
  

  protected
  
    def session_store_key
      :authentication_return_to
    end

  end
end
