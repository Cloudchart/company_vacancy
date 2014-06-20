require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class IdentitiesController < ApplicationController
    
    # Create identity
    #
    def create
      chart     = Chart.find(params[:chart_id])
      identity  = Identity.new(identity_params)

      chart.identities << identity

      respond_to do |format|
        format.json do
          render json: identity.as_json_for_chart
        end 
      end
    end
    
    
    # Update identity
    #
    def update
    end
    
    
    # Destroy identity
    #
    def destroy
    end
    
    
    private
    
    def identity_params
      params.require(:identity).permit(permitted_identity_params)
    end
    
    def permitted_identity_params
      [:uuid, :node_id, :identity_id, :identity_type, :is_primary]
    end
    
  end
end
