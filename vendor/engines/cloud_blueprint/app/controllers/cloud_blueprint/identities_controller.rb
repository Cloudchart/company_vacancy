require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class NodesController < ApplicationController
    
    # Create identity
    #
    def create
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
