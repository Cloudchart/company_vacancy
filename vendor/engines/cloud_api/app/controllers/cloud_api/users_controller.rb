require_dependency "cloud_api/application_controller"

module CloudApi
  class UsersController < CloudApi::ApplicationController

    def me
      @source   = User
      @starter  = [:find, current_user.uuid]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    def unicorns
      @source   = User
      @starter  = [:unicorns]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    def show
      @source = User
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json { render '/main' }
      end      
    end
  end
end
