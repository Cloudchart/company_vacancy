require_dependency "cloud_api/application_controller"

module CloudApi
  class PinsController < CloudApi::ApplicationController

    def show
      @source = pin_source.find(params[:id])

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    private

    def pin_source
      if current_user.editor?
        Pin
      else
        current_user.pins
      end
    end

  end
end
