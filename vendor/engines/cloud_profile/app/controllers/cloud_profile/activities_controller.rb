require_dependency "cloud_profile/application_controller"

module CloudProfile
  class ActivitiesController < ApplicationController
    respond_to :html, :js
    before_action :require_authenticated_user!

    def index
      @activities = Activity.includes(:user, :trackable, :source).by_user_or_companies(current_user).order(created_at: :desc).page(params[:page])
      respond_with @activities
    end

  end
end
