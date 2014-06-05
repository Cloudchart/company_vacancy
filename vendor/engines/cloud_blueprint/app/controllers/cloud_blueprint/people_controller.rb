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
    
    
    # Create new person for chart
    # POST /charts/:id/people
    #
    def create
      chart    = Chart.includes(:company).find(params[:chart_id])
      person   = Person.new person_params_for_create

      chart.company.people << person

      respond_to do |format|
        format.json { render json: person.as_json_for_chart }
      end
    end
    

    # Update person
    # PUT /charts/:id/people/:id
    #
    def update
      chart    = Chart.find(params[:chart_id])
      person   = chart.people.find(params[:id])

      person.update! person_params_for_update
      
      respond_to do |format|
        format.json { render json: person.as_json_for_chart }
      end
    end
    
    
    # Destroy person
    # DELETE /charts/:id/people/:id
    #
    def destroy
      chart    = Chart.find(params[:chart_id])
      person   = chart.people.find(params[:id])

      person.destroy
      
      respond_to do |format|
        format.json { render json: person.as_json_for_chart }
      end
    end


    private
    

    def person_params_for_create
      params.require(:person).permit(:uuid, :first_name, :last_name, :occupation)
    end

    def person_params_for_update
      params.require(:person).permit(:first_name, :last_name, :occupation)
    end


  end
end
