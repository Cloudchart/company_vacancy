require_dependency "cloud_profile/application_controller"

module CloudProfile
  class AuthenticationsController < ApplicationController

    def new
      redirect_to main_app.root_path if current_user.present? 
    end

    def create
      email = Email.includes(:user).find_by(address: params[:email])
      raise ActiveRecord::RecordNotFound unless email.present? && email.user.present? && email.user.authenticate(params[:password])
      warden.set_user(email.user, scope: :user)

      respond_to do |format|
        format.json { render json: { previous_path: previous_path } }
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

  private

    def previous_path
      if current_user.is_admin? && current_user.email == ENV['DEFAULT_ADMIN_EMAIL']
        rails_admin.dashboard_path
      else
        session[:previous_path]
      end 
    end
  end
end
