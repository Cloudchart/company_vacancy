require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class VacanciesController < ApplicationController
    
    # List vacancies for chart
    # GET /charts/:id/vacancies
    #
    def index
      @chart = Chart.includes(:vacancies).find(params[:chart_id])
      respond_to do |format|
        format.json do
          render json: @chart.vacancies.as_json_for_chart
        end
      end
    end
    
    
    # Create new vacancy for chart
    # POST /charts/:id/vacancies
    #
    def create
      chart    = Chart.includes(:company).find(params[:chart_id])
      vacancy  = Vacancy.new vacancy_params_for_create

      vacancy.author = current_user
      chart.company.vacancies << vacancy

      respond_to do |format|
        format.json { render json: vacancy.as_json_for_chart }
      end
    end
    
    
    # Update vacancy
    # PUT /charts/:id/vacancies/:id
    #
    def update
      chart    = Chart.find(params[:chart_id])
      vacancy  = chart.vacancies.find(params[:id])

      vacancy.update vacancy_params_for_update
      
      respond_to do |format|
        format.json { render json: vacancy.as_json_for_chart }
      end
    end
    
    
    # Destroy vacancy
    # DELETE /charts/:id/vacancies/:id
    #
    def destroy
      chart    = Chart.find(params[:chart_id])
      vacancy  = chart.vacancies.find(params[:id])

      vacancy.destroy unless chart.identities.where(identity_id: vacancy.to_param).size > 0      

      respond_to do |format|
        format.json { render json: vacancy.as_json_for_chart }
      end
    end
    
    
    private
    
    def vacancy_params_for_create
      params.require(:vacancy).permit([:uuid, :name, :description])
    end
    
    def vacancy_params_for_update
      params.require(:vacancy).permit([:name, :description])
    end
    
  end
end
