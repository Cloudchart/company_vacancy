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
      @chart  = Chart.find(params[:chart_id])
      @node   = Node.new(node_params)
      @chart.nodes << @node

      respond_to do |format|
        format.html { redirect_to @chart }
        format.json do
          render json: @node.as_json_for_chart
        end 
      end
    end
    
    
    # Edit node
    # GET /charts/:id/nodes/:id/edit
    #
    def edit
      @chart  = Chart.find(params[:chart_id])
      @node   = @chart.nodes.includes(:children).find(params[:id])
      
      respond_to do |format|
        format.js
      end
    end
    
    
    # Update node
    # PUT /charts/:id/nodes/:id
    #
    def update
      @chart  = Chart.find(params[:chart_id])
      @node   = @chart.nodes.find(params[:id])
      @node.update! node_params
      
      respond_to do |format|
        format.json do
          render json: @node.as_json_for_chart
        end
      end
    end
    
    
    def update_batch
      @chart  = Chart.find(params[:chart_id])
      
      Node.transaction do
        params[:create_nodes].each do |pair|
          node_params = ActionController::Parameters.new(pair.last)
          node        = Node.new node_params.permit(permitted_node_params)
          @chart.nodes << node
        end if params[:create_nodes]
        
        params[:update_nodes].each do |pair|
          node_params = ActionController::Parameters.new(pair.last)
          node        = Node.find(node_params[:uuid])
          node.update! node_params.permit(permitted_node_params)
        end if params[:update_nodes]
        
        params[:delete_nodes].each do |uuid|
          Node.destroy(uuid) rescue nil
        end if params[:delete_nodes]
      end
    
    ensure
      render nothing: true
    end
    
    # Destroy node
    # DELETE /charts/:id/nodes/:id
    #
    def destroy
      chart = Chart.find(params[:chart_id])
      node  = chart.nodes.includes(:children).find(params[:id])
      
      node.destroy if node.children.length == 0
      
      respond_to do |format|
        format.json { render json: node.as_json_for_chart }
      end
    end
    
    
    private
    
    
    def node_params
      params.require(:node).permit(permitted_node_params)
    end
    
    def permitted_node_params
      [:uuid, :title, :parent_id, :position, :color_index, :knots]
    end
    
  end
end
