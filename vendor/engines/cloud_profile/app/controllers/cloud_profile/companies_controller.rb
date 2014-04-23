require_dependency "cloud_profile/application_controller"

module CloudProfile
  class CompaniesController < ApplicationController

    def index
      @companies = current_user.companies.order(created_at: :desc)
    end  

  end
end
