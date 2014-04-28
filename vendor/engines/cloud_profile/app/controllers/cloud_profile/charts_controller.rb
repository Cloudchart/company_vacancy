require_dependency "cloud_profile/application_controller"

module CloudProfile
  class ChartsController < ApplicationController

    def index
      @companies = current_user.companies.order(created_at: :desc)
    end  

  end
end
