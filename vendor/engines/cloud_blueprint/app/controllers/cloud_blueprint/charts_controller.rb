require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class ChartsController < ApplicationController
    
    before_action :require_authenticated_user!
    
    
    # Render chart
    # GET /charts/:id
    #
    def show
      @chart      = Chart.find(params[:id])
      respond_to do |format|
        format.html
        format.json do
          
          @vacancies = @chart.company.vacancies
          
          render json: {
            vacancies: @vacancies.as_json(only: [:uuid, :name, :description])
          }
          
        end
      end
    end


    # New chart
    # GET /charts/new
    #
    def new
      @chart      = Chart.new
      @companies  = current_user.companies.where(is_empty: false)
    end
    

    # Create chart
    # POST /charts
    #
    def create
      @companies  = current_user.companies.where(is_empty: false)
      
      redirect_to new_chart_path and return unless @companies.map(&:to_param).include?(params[:chart][:company_id])
      
      @chart      = Chart.new params.require(:chart).permit(:title, :company_id)
      @chart.save!

      redirect_to cloud_profile.charts_path

    rescue ActiveRecord::RecordInvalid
      render :new
    end
    
    
  end
end
