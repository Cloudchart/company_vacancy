require_dependency "cloud_profile/application_controller"

module CloudProfile
  class UsersController < ApplicationController
    
    # Registration form
    def new
      @email = Email.new address: params[:email]
      @user  = User.new
    end
    
    # Registration
    def create
      @email  = Email.new address: params[:email]
      @user   = User.new password: params[:password], password_confirmation: params[:password]
      @user.emails << @email
      
      @user.save!
      
      EmailMailer.activation_email(@email).deliver
    
    rescue ActiveRecord::RecordInvalid
      render :new
    end
    
  end
end
