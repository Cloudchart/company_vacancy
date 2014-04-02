require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController


    before_filter :find_social_network, only: :new
    

    def new
      store_return_path unless return_path_stored?
      
      if @social_network.present?
        redirect_to register_path(social_network_id: @social_network.to_param) and return
      end

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

      raise ActiveRecord::RecordNotFound  unless email.present? || email.user.authenticate(params[:password])
      raise ActiveRecord::RecordInvalid   unless email.active?

      warden.set_user(email.user, scope: :user)
      redirect_to_stored_path_or_root and return

    rescue ActiveRecord::RecordNotFound
      render :new

    rescue ActiveRecord::RecordInvalid
      render :new
    end
    

    def destroy
      warden.logout
      redirect_to_stored_path_or_root
    end
  

  protected
  
    def find_social_network
      @social_network = SocialNetwork.includes(:user).find(session.delete(:social_network_id)) rescue nil
    end
  
    def session_store_key
      :authentication_return_to
    end

  end
end
