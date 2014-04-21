require_dependency "cloud_profile/application_controller"

module CloudProfile
  class WelcomeController < ApplicationController

    before_action :require_authenticated_user!
    
  end
end
