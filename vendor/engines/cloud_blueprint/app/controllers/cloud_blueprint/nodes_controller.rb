require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class NodesController < ApplicationController
    
    # List nodes for chart
    # GET /charts/:id/nodes
    #
    def index
      @chart  = Chart.find(params[:chart_id])

      respond_to do |format|
        format.json do
          render json: @chart.nodes.order(:position).as_json(only: [:uuid, :chart_id, :parent_id, :title, :position])
        end
      end
    end
    

    # New node
    # GET /charts/:id/nodes/new
    #
    def new
      @chart  = Chart.find(params[:chart_id])
      @node   = @chart.nodes.build

      respond_to do |format|
        format.js
      end
    end
    
    
    # Create chart node
    # POST /charts/:id/nodes
    #
    def create
      @chart = Chart.find(params[:chart_id])
      @node  = Node.new(node_params)
      @chart.nodes << @node
      respond_to do |format|
        format.html { redirect_to @chart }
      end
    end
    
    
    # Edit node
    # GET /charts/:id/nodes/:id/edit
    #
    def edit
      @chart  = Chart.find(params[:chart_id])
      @node   = @chart.nodes.find(params[:id])
      
      respond_to do |format|
        format.js
      end
    end
    
    
    private
    
    
    def node_params
      params.require(:node).permit([:title, :parent_id, :position])
    end
    
  end
end
