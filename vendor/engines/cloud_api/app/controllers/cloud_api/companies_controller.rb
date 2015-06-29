require_dependency "cloud_api/application_controller"

module CloudApi
  class CompaniesController < CloudApi::ApplicationController

    def show
      @source   = Company
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json do
          render_cached_main_json(expires_in: 1.minute)
        end
      end
    end

  end
end
