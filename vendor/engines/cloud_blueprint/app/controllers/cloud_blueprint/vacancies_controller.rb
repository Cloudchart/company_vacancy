require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class VacanciesController < ApplicationController
    
    # List vacancies for chart
    # GET /charts/:id/vacancies
    #
    def index
      @chart = Chart.includes(company: :vacancies).find(params[:chart_id])
      respond_to do |format|
        format.json do
          render json: @chart.company.vacancies.as_json(only: [:uuid, :name, :description])
        end
      end
    end
    
    
    # New vacancy
    # Get /charts/:id/vacancies/new
    #
    def new
      @chart    = Chart.find(params[:chart_id])
      @vacancy  = Vacancy.new

      respond_to do |format|
        format.js
      end
    end
    
    
    # Create new vacancy for chart
    # POST /charts/:id/vacancies
    #
    def create
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @vacancy  = Vacancy.new vacancy_params
      @chart.company.vacancies << @vacancy
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    
    # Edit vacancy
    # GET /charts/:id/vacancies/:id
    #
    def edit
      @chart    = Chart.find(params[:chart_id])
      @vacancy  = Vacancy.find(params[:id])

      respond_to do |format|
        format.js
      end
    end
    
    
    # Update vacancy
    # PUT /charts/:id/vacancies/:id
    #
    def update
      @chart    = Chart.find(params[:chart_id])
      @vacancy  = Vacancy.find(params[:id])
      @vacancy.update vacancy_params
      
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    
    # Push vacancies
    # PUT /charts/:id/vacancies/push
    #
    def push
      @company = Chart.includes(:company).find(params[:chart_id]).company

      Vacancy.transaction do
      end
      
    ensure
      render nothing: true
    end
    
    
    # Destroy vacancy
    # DELETE /charts/:id/vacancies/:id
    #
    def destroy
      @chart    = Chart.find(params[:chart_id])
      @vacancy  = Vacancy.find(params[:id])
      @vacancy.destroy
      
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    
    private
    
    def vacancy_params
      params.require(:vacancy).permit([:name, :description])
    end
    
  end
end
