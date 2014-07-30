require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class ChartsController < ApplicationController
    
    skip_before_action :require_authenticated_user!, only: :preview, if: -> { request.format.json? }
    before_action :set_chart, only: [:show, :pull, :update]
    authorize_resource
    
    
    # Render chart
    # GET /charts/:id
    #
    def show
      respond_to do |format|
        format.html
      end
    end
    
    
    # Load chart preview
    #
    def preview
      chart = Chart.includes(nodes: { identities: :identity }).find(params[:id])
      
      respond_to do |format|
        format.json {
          render json: chart, include: {
            nodes: { 
              include: {
                identities: {
                  include: :identity
                }
              }
            }
          } 
        }
      end
    end

    
    # Synchronize chart
    # GET /charts/:id/pull
    #
    def pull
      last_accessed_at = Time.at(params[:last_accessed_at].to_i / 1000)
      
      respond_to do |format|
        format.json do
          render json: {
            available_vacancies:    @chart.vacancies.select(:uuid).map(&:uuid),
            vacancies:              @chart.vacancies.later_then(last_accessed_at).map(&:as_json_for_chart),
            available_people:       @chart.people.select(:uuid).map(&:uuid),
            people:                 @chart.people.later_then(last_accessed_at).map(&:as_json_for_chart),
            available_nodes:        @chart.nodes.select(:uuid).map(&:uuid),
            nodes:                  @chart.nodes.later_then(last_accessed_at).map(&:as_json_for_chart),
            available_identities:   @chart.identities.select(:uuid).map(&:uuid),
            identities:             @chart.identities.later_then(last_accessed_at).map(&:as_json_for_chart),
            last_accessed_at:       Time.now
          }
        end
      end
    end


    # New chart
    # GET /charts/new
    #
    def new
      company = current_user.companies.find(params[:company_id])
      chart   = Chart.new(title: 'Default Chart')
      company.charts << chart
      redirect_to chart
    rescue ActiveRecord::RecordNotFound
      redirect_to :back and return unless company
    end
    

    # Create chart
    # POST /charts
    #
    def create
      @companies  = current_user.companies
      
      redirect_to new_chart_path and return unless @companies.map(&:to_param).include?(params[:chart][:company_id])
      
      @chart      = Chart.new params.require(:chart).permit(:title, :company_id)
      @chart.save!

      redirect_to @chart

    rescue ActiveRecord::RecordInvalid
      render :new
    end
    
    
    # Update chart
    # PUT /charts/:id
    #
    def update
      @chart.update! params.require(:chart).permit(:title)
      
      respond_to do |format|
        format.json do
          render json: @chart, only: [:uuid, :title]
        end
      end
    end


  private

    def set_chart
      @chart = Chart.find(params[:id])
    end
    
        
  end
end
