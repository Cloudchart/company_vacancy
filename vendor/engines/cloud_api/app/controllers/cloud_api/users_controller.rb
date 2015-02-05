require_dependency "cloud_api/application_controller"

module CloudApi
  class UsersController < CloudApi::ApplicationController

    def me
      @source = current_user

      respond_to do |format|
        format.json { render '/main' }
      end
    end


    def unicorns
      raise CanCan::AccessDenied unless current_user.try(:editor?)

      @source = User.unicorns

      respond_to do |format|
        format.json { render '/main' }
      end
    end


  end
end
