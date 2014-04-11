require_dependency "cloud_profile/application_controller"

module CloudProfile
  class WelcomeController < ApplicationController

    before_action :require_authenticated_user!

    def newsfeed
      @versions = PaperTrail::Version.where(whodunnit: current_user.id)
    end
    
  protected
  
    def require_authenticated_user!
      redirect_to main_app.root_path unless user_authenticated?
    end
    
  end
end
