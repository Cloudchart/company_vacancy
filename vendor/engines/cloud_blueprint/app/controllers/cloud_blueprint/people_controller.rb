require_dependency "cloud_blueprint/application_controller"

module CloudBlueprint
  class PeopleController < ApplicationController

    # List people for chart
    #
    def index
      @chart = Chart.includes(company: :people).find(params[:chart_id])
      respond_to do |format|
        format.json do
          render json: @chart.company.people, root: false
        end
      end
    end
    
    
    # Create new person for chart
    # POST /charts/:id/people
    #
    def create
      chart    = Chart.includes(:company).find(params[:chart_id])
      person   = chart.company.people.create! person_params_for_create

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

      person.destroy unless chart.identities.where(identity_id: person.to_param).size > 0
      
      respond_to do |format|
        format.json { render json: person.as_json_for_chart }
      end
    end


    private
    

    def person_params_for_create
      params.require(:person).permit(:uuid, :full_name, :occupation)
    end

    def person_params_for_update
      params.require(:person).permit(:full_name, :occupation)
    end


  end
end
