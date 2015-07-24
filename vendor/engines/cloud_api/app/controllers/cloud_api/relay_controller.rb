require_dependency "cloud_api/application_controller"

module CloudApi
  class RelayController < CloudApi::ApplicationController

    include QueryHelper

    def fetch
      source    = params[:type].constantize.find(params[:id])
      query     = parse_relations_query(params[:fields])

      shape = BaseShape.shape(source, query, ability: Ability.new(current_user))

      respond_to do |format|
        format.json do
          render json: shape
        end
      end
    end

  end
end
