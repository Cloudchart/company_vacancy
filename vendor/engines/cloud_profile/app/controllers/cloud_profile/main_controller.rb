require_dependency "cloud_profile/application_controller"

module CloudProfile
  class MainController < ApplicationController
    authorize_resource class: :cloud_profile_main
    
    def companies
      # TODO 
      # rewrite n+1 query for invited_by_companies, change three merges
      my_companies = current_user.companies.includes(:people, :tags).order(updated_at: :desc).all
      followed_companies = current_user.followed_companies.includes(:people, :tags).order(updated_at: :desc).all
      invited_by_companies = current_user.invited_by_companies

      @companies = my_companies + followed_companies + invited_by_companies
      company_ids = @companies.map(&:id)

      @tokens = current_user.company_invite_tokens
      @roles = current_user.roles.where(owner_type: 'Company', owner_id: company_ids)
      @favorites = current_user.favorites.where(favoritable_type: 'Company', favoritable_id: company_ids)
    end

    def vacancies
      @companies = current_user.companies.includes(:vacancies).order(updated_at: :desc)
    end

    def activities
      @activities = Activity.includes(:user, :trackable, :source).by_user_or_companies(current_user).order(created_at: :desc).page(params[:page])
    end

    def settings
    end

    def subscriptions
      @subscriptions = current_user.subscriptions.order(created_at: :desc)
    end

  end
end
