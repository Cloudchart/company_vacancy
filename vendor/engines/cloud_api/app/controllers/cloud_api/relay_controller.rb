require_dependency "cloud_api/application_controller"

module CloudApi
  class RelayController < CloudApi::ApplicationController

    def fetch
      @source   = params[:type].constantize
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json do
          render_cached_main_json(expires_in: 10.minutes)
        end
      end
    end

  end
end
