require_dependency "cloud_profile/application_controller"

module CloudProfile
  class MainController < ApplicationController

    before_action :handle_company_invite_token, only: :settings, if: 'params[:token_id].present?'

    # TODO: use cancan instead
    before_action :require_authenticated_user!

    before_action :create_default_company, only: :companies, if: 'current_user.companies.blank?'
    
    def companies
      @companies = current_user.companies.includes(:industries, :people, :vacancies, :favorites, :charts)
      @companies = order_by_updated_at_or_favorites(@companies)
    end

    def vacancies
      @companies = current_user.companies.includes(:vacancies, :favorites)
      @companies = order_by_updated_at_or_favorites(@companies)
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

    def handle_company_invite_token
      token = Token.find(params[:token_id]) rescue nil

      if token
        session[:company_invite] ||= []
        session_data = { token_id: token.id, company_id: Person.find(token.data).company_id }
        session[:company_invite] << session_data unless session[:company_invite].include?(session_data)
      end

      redirect_to cloud_profile.login_path unless current_user
    end

    def create_default_company
      redirect_to main_app.new_company_path
    end

    def order_by_updated_at_or_favorites(collection)
      if collection.joins(:favorites).any?
        collection.order('favorites.created_at DESC')
      else
        collection.order(updated_at: :desc)
      end      
    end

  end
end
