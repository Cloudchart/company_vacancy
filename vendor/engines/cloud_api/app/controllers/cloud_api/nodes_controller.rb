require_dependency "cloud_api/application_controller"

module CloudApi
  class NodesController < CloudApi::ApplicationController

    respond_to :json


    def fetch
      node = params[:type].constantize.find(params[:id])

      render json: node
    end


  end
end
