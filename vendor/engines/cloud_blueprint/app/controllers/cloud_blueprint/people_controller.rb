require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class PeopleController < ApplicationController

    # List people for chart
    #
    def index
      @chart = Chart.includes(company: :people).find(params[:chart_id])
      respond_to do |format|
        format.json do
          render json: @chart.company.people.as_json(only: [:uuid, :first_name, :last_name, :occupation])
        end
      end
    end
    
    
    # New person
    # Get /charts/:id/people/new
    #
    def new
      @chart    = Chart.find(params[:chart_id])
      @person   = Person.new

      respond_to do |format|
        format.js
      end
    end


    # Create new person for chart
    # POST /charts/:id/people
    #
    def create
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @person   = Person.new person_params
      @chart.company.people << @person
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    

    # Edit person
    # GET /charts/:id/people/:id
    #
    def edit
      @chart    = Chart.find(params[:chart_id])
      @person   = Person.find(params[:id])

      respond_to do |format|
        format.js
      end
    end


    # Update person
    # PUT /charts/:id/people/:id
    #
    def update
      @chart    = Chart.find(params[:chart_id])
      @person   = Person.find(params[:id])
      @person.update person_params
      
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    
    # Destroy person
    # DELETE /charts/:id/people/:id
    #
    def destroy
      @chart    = Chart.find(params[:chart_id])
      @person   = Person.find(params[:id])
      @person.destroy
      
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end


    private
    
    def person_params
      params.require(:person).permit([:first_name, :last_name, :occupation])
    end

  end
end
