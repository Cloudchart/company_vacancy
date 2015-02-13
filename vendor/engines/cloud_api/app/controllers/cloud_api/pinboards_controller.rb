require_dependency "cloud_api/application_controller"

module CloudApi
  class PinboardsController < CloudApi::ApplicationController

    def show
      @source   = Pinboard
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

  end
end
