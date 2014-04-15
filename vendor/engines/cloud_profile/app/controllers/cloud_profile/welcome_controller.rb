require_dependency "cloud_profile/application_controller"

module CloudProfile
  class WelcomeController < ApplicationController

    before_action :require_authenticated_user!

    def newsfeed
      @activities = Activity.by_user_or_companies(current_user).order(created_at: :desc)
    end
    
  protected
  
    def require_authenticated_user!
      redirect_to main_app.root_path unless user_authenticated?
    end
    
  end
end
