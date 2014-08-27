require_dependency "cloud_profile/application_controller"

module CloudProfile
  class MainController < ApplicationController
    before_action :handle_company_invite_token, only: :companies

    # TODO: use cancan instead
    before_action :require_authenticated_user!

    before_action :create_default_company, only: :companies, if: -> { current_user.companies.blank? }
    
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
      token_id = if params[:token].present?
        Cloudchart::RFC1751.decode(params[:token].gsub(/-/, ' '))
      elsif session[:company_invite].present?
        session[:company_invite]
      else
        nil
      end

      return unless token_id

      token = Token.where(name: :company_invite).find(token_id) rescue nil

      if token && current_user
        person = Person.find(token.data[:person_id])

        unless current_user.people.map(&:company_id).include?(person.company_id)
          current_user.people << person
          
          # TODO: add default subscription
          # current_user.subscriptions.find_by(subscribable: person.company).try(:destroy)
          # current_user.subscriptions.create!(subscribable: person.company, types: [:vacancies, :events])

          token.destroy
          session[:company_invite] = nil if session[:company_invite].present?
        end

      elsif token
        session[:company_invite] = token.id
        redirect_to main_app.root_path(anchor: :login)
      end
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
