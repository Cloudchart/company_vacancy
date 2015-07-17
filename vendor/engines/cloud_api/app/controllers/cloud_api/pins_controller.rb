require_dependency "cloud_api/application_controller"

module CloudApi
  class PinsController < CloudApi::ApplicationController

    def show
      @source   = Pin
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json do
          render_cached_main_json(expires_in: 10.minutes)
        end
      end
    end

  end
end
