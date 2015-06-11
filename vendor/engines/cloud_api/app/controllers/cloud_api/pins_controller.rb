require_dependency "cloud_api/application_controller"

module CloudApi
  class PinsController < CloudApi::ApplicationController

    def show
      @source   = Pin
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

  end
end
