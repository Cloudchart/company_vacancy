require_dependency "cloud_api/application_controller"

module CloudApi
  class RelayController < CloudApi::ApplicationController

    include QueryHelper

    def fetch
      source    = params[:type].constantize.find(params[:id])
      query     = parse_relations_query(params[:fields])

      ability       = Ability.new(current_user)
      permissions   = ability.permissions

      shape = BaseShape.shape(source, query, ability: ability, persmissions: permissions)

      respond_to do |format|
        format.json do
          render json: shape
        end
      end
    end


    def graphql
      render json: { yeah: true }
    end


  end
end
