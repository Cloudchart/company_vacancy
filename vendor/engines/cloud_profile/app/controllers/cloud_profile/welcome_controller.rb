require_dependency "cloud_profile/application_controller"

module CloudProfile
  class WelcomeController < ApplicationController

    before_action :require_authenticated_user!
    
    def settings
      @social_networks = current_user.social_networks
    end
    
  end
end
