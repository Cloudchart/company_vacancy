require_dependency "cloud_profile/application_controller"

module CloudProfile
  class SubscriptionsController < ApplicationController

    def index
      @subscriptions = current_user.subscriptions.order(created_at: :desc)
    end

  end
end
