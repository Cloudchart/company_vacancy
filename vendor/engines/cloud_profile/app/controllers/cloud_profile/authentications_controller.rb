require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController

    def create
      email = Email.includes(:user).find_by(address: params[:email])
      raise ActiveRecord::RecordNotFound unless email.present? && email.user.present? && email.user.authenticate(params[:password])
      warden.set_user(email.user, scope: :user)
 
      respond_to do |format|
        format.json { render json: { admin_path: (rails_admin.dashboard_path if current_user.is_admin?) } }
      end
      
    rescue ActiveRecord::RecordNotFound
      
      respond_to do |format|
        format.json { render json: 'nok', status: 412 }
      end

    end
    
    def destroy
      warden.logout(:user)
      redirect_to main_app.root_path
    end

  end
end
