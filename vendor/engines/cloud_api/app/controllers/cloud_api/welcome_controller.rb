require_dependency "cloud_api/application_controller"

module CloudApi
  class WelcomeController < CloudApi::ApplicationController

    def index
      render json: 200
    end

  end
end
