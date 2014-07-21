require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController

    
    before_action :redirect_authenticated_user, except: :destroy
    

    def new
      store_return_path unless return_path_stored?

      @email = Email.find_or_initialize_by(address: params[:email])

      if @email.valid?
        if @email.persisted?
          render :create
        else
          redirect_to register_path(email: @email.address)
        end
      else
        render :new
      end

    end
    
    
    def create
      email = Email.find_by(address: params[:email])
      raise ActiveRecord::RecordNotFound unless email.present? && email.user.present? && email.user.authenticate(params[:password])
      warden.set_user(email.user, scope: :user)
      redirect_to_stored_path_or cloud_profile.companies_path
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = 'So email. Much credentials. Very password. Wow. But no.'
      @email = Email.new(address: params[:email])
    end
    
    
    def destroy
      store_return_path
      warden.logout(:user)
      redirect_to_stored_path_or_root
    end
    

  protected
  
  
    def redirect_authenticated_user
      redirect_to_stored_path_or_root if user_authenticated?
    end
  
  
    def session_store_key
      :authentication_return_to
    end
  

  end
end
