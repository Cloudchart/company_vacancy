require_dependency "cloud_api/application_controller"

module CloudApi
  class UsersController < CloudApi::ApplicationController

    def me
      @user = current_user

      respond_to do |format|
        format.json { render :show }
      end
    end


    def unicorns
      respond_to do |format|
        format.json
      end
    end

  end
end
