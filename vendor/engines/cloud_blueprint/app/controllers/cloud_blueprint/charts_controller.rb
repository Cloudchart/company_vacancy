require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class ChartsController < ApplicationController    
    before_action :set_company, only: [:show, :new]
    before_action :set_chart, only: [:show, :pull, :update]

    authorize_resource
    
    # Render chart
    #
    def show      
      pagescript_params editable: can?(:edit, @chart)
      
      respond_to do |format|
        format.html
        format.json { render json: @chart }
      end
    end
    
    
    # New chart component controller
    #
    def view
      respond_to do |format|
        format.html

        format.json do
          chart = Chart.includes(:company).find(params[:id])
          render json: chart, serializer: CloudBlueprint::ChartSerializer, root: false
        end
      end
    end
    
    
    # Load chart preview
    #
    def preview
      @chart = Chart.includes(nodes: { identities: :identity }).find(params[:id])
      
      respond_to do |format|
        format.json {
          render json: @chart.to_json( include: {
            nodes: { 
              include: {
                identities: {
                  include: :identity
                }
              }
            }
          }) 
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
            available_vacancies:    @chart.company.vacancies.select(:uuid).map(&:uuid),
            vacancies:              @chart.company.vacancies.later_then(last_accessed_at).map(&:as_json_for_chart),
            available_people:       @chart.company.people.select(:uuid).map(&:uuid),
            people:                 ActiveModel::ArraySerializer.new(@chart.company.people.later_then(last_accessed_at), each_serializer: CloudBlueprint::PersonSerializer).as_json,
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
    #
    def new
      chart = Chart.new(title: 'Default Chart')
      @company.charts << chart
      redirect_to company_chart_path(@company, chart)
    rescue ActiveRecord::RecordNotFound
      redirect_to :back and return unless @company
    end
    

    # Create chart
    # POST /charts
    #
    def create
      @companies = current_user.companies
      
      redirect_to new_chart_path and return unless @companies.map(&:to_param).include?(params[:chart][:company_id])
      
      @chart = Chart.new params.require(:chart).permit(:title, :company_id)
      @chart.save!

      redirect_to @chart

    rescue ActiveRecord::RecordInvalid
      render :new
    end
    
    
    # Update chart
    # PUT /charts/:id
    #
    def update
      @chart.update! params.require(:chart).permit([:title, :is_public])
      
      respond_to do |format|
        format.json { render json: @chart }
      end
      
    rescue ActiveRecord::RecordInvalid
      
      respond_to do |format|
        format.json { render json: @chart.reload, status: 422 }
      end
    end


  private

    def set_company
      @company = Company.find(params[:company_id])
    end

    def set_chart
      @chart = if params[:company_id].present?
        @company.charts.find_by(slug: params[:id]) || @company.charts.find(params[:id])
      else
        Chart.find(params[:id])
      end
    end
        
  end
end
