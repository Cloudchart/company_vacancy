require_dependency "cloud_profile/application_controller"

module CloudProfile
  class PasswordsController < ApplicationController

    before_action :require_authenticated_user!
    
    
    def update
      if current_user.authenticate(params[:current_password])
        current_user.update!(password: params[:password], password_confirmation: params[:password_confirmation])
        redirect_to :settings
      else
        current_user.errors.add(:current_password, :invalid)
        render :show
      end
    rescue ActiveRecord::RecordInvalid
      render :show
    end
    

  end
end
