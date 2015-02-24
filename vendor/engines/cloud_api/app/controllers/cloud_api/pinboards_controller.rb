require_dependency "cloud_api/application_controller"

module CloudApi
  class PinboardsController < CloudApi::ApplicationController

    def show
      @source   = Pinboard
      @starter  = if params[:id] == 'system'
        [:system]
      else
        [:find, params[:id]]
      end

      respond_to do |format|
        format.json { render '/main' }
      end
    end

  end
end