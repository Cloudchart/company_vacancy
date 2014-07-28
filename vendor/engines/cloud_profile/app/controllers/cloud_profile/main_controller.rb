require_dependency "cloud_profile/application_controller"

module CloudProfile
  class MainController < ApplicationController

    before_action :handle_company_invite_token, only: :settings, if: 'params[:token_id].present?'
    before_action :require_authenticated_user!
    
    def companies
      @companies = current_user.companies.includes(:industries, :people, :vacancies, :favorites, :charts).order('favorites.created_at DESC')
    end

    def vacancies
      @companies = current_user.companies.joins(:vacancies).includes(:favorites).order('favorites.created_at DESC')
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

  end
end
