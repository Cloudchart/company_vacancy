require_dependency "cloud_profile/application_controller"

module CloudProfile
  class UsersController < ApplicationController

    before_action :find_social_network
    
    # Registration form
    def new
      store_return_path if params[:return_to].present? || !return_path_stored?
      
      @email = Email.new address: params[:email]
      @user  = User.new
      fill_email_address_by_social_network
    end
    
    # Registration
    def create
      @email  = Email.new address: params[:email]
      @user   = User.new password: params[:password], password_confirmation: params[:password]
      @user.emails << @email
      
      @user.save!
      
      EmailMailer.activation_email(@email).deliver
      
      redirect_to_stored_path_or_root
    
    rescue ActiveRecord::RecordInvalid
      fill_email_address_by_social_network
      render :new
    end
    
  protected
    
    def find_social_network
      @social_network = SocialNetwork.find(params[:social_network_id]) rescue nil
    end
    
    def fill_email_address_by_social_network
      @email.address = @social_network.email if @email.address.blank? && @social_network.present?
    end
    
    def session_store_key
      :user_return_to
    end
    
  end
end
