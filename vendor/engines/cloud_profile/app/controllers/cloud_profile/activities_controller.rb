require_dependency "cloud_profile/application_controller"

module CloudProfile
  class ActivitiesController < ApplicationController

    def index
      @activities = Activity.by_user_or_companies(current_user).order(created_at: :desc)
    end  

  end
end
