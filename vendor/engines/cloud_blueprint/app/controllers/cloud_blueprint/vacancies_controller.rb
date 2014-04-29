require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class VacanciesController < ApplicationController
    
    # Create new vacancy for chart
    # POST /charts/:id/vacancies
    #
    def create
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @vacancy  = Vacancy.new(params.require(:vacancy).permit([:name, :description]))
      @chart.company.vacancies << @vacancy
      respond_to do |format|
      end
    end
    
  end
end
