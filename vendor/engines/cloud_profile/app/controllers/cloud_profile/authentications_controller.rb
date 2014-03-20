require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController
    

    def new
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
      redirect_to_stored_path_or_root and return if email.present? && email.user.authenticate(params[:password])
      flash.now[:error] = 'No user'
    end
  

  private
  

    def store_return_path
      session[:authentication_return_to] = params[:return_to] if params[:return_to]
    end
    

    def redirect_to_stored_path_or_root
      redirect_to params[:return_to] || session[:authentication_return_to] || :profile
      session[:authentication_return_to] = nil
    end


  end
end
