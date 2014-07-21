require_dependency "cloud_profile/application_controller"

module CloudProfile
  class MainController < ApplicationController

    before_action :require_authenticated_user!
    
    def companies
      @companies = current_user.companies.includes(:logo, :industries, :people, :vacancies, :favorites, :charts).order('favorites.created_at DESC')
    end

    def vacancies
      @companies = current_user.companies.includes(:vacancies, :favorites).order('favorites.created_at DESC')
    end

    def activities
      @activities = Activity.includes(:user, :trackable, :source).by_user_or_companies(current_user).order(created_at: :desc).page(params[:page])
    end

    def settings
      pagescript_params(
        personal: PersonalSerializer.new(current_user).as_json(root: false)
      )

      @social_networks = current_user.social_networks
    end

    def subscriptions
      @subscriptions = current_user.subscriptions.order(created_at: :desc)
    end

  end
end
