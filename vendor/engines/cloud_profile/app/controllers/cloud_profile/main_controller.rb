require_dependency "cloud_profile/application_controller"

module CloudProfile
  class MainController < ApplicationController
    authorize_resource class: :cloud_profile_main
    before_action :create_default_company, only: :companies, unless: -> { current_user.companies.any? }
    
    def companies
      @companies = current_user.companies.includes(:people, :tags).order(updated_at: :desc)
    end

    def vacancies
      @companies = current_user.companies.includes(:vacancies).order(updated_at: :desc)
    end

    def activities
      @activities = Activity.includes(:user, :trackable, :source).by_user_or_companies(current_user).order(created_at: :desc).page(params[:page])
    end

    def settings
      pagescript_params(
        personal: PersonalSerializer.new(current_user).as_json(root: false),
        emails_path: emails_path
      )

      @social_networks = current_user.social_networks
    end

    def subscriptions
      @subscriptions = current_user.subscriptions.order(created_at: :desc)
    end

  private

    def create_default_company
      redirect_to main_app.new_company_path
    end

  end
end
