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
      errors = validate_login(email)

      if errors.values.size > 0
        respond_to do |format|
          format.json { render json: { errors: errors } }
        end
      else
        respond_to do |format|
          format.json { render json: 'nok', status: 412 }
        end
      end
    end
    
    def destroy
      warden.logout(:user)
      redirect_to main_app.root_path
    end

  private

    def validate_login(email)
      errors = {}

      if !params[:email].present?
        errors[:email] = ['missing']
      elsif !email.present? || !email.user.present?
        errors[:email] = ['invalid']
      elsif !email.user.authenticate(params[:password])
        errors[:password] = ['invalid']
      end

      errors
    end
  end
end
