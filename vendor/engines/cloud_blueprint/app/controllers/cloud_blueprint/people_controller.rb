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
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @person   = @chart.company.people.build

      respond_to do |format|
        format.js { render :form }
      end
    end


    # Create new person for chart
    # POST /charts/:id/people
    #
    def create
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @person   = @chart.company.people.build person_params

      @person.save!

      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    

    # Edit person
    # GET /charts/:id/people/:id
    #
    def edit
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @person   = @chart.company.people.find(params[:id])

      respond_to do |format|
        format.js { render :form }
      end
    end


    # Update person
    # PUT /charts/:id/people/:id
    #
    def update
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @person   = @chart.company.people.find(params[:id])

      @person.update! person_params
      
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end
    
    
    # Push people
    # PUT /charts/:id/people
    #
    def push
      company = Chart.includes(:company).find(params[:chart_id]).company

      Person.transaction do
        create_people(company)
        update_people(company)
        delete_people(company)
      end

    ensure
      render nothing: true
    end
    
    
    # Destroy person
    # DELETE /charts/:id/people/:id
    #
    def destroy
      @chart    = Chart.includes(:company).find(params[:chart_id])
      @person   = @chart.company.people.find(params[:id])

      @person.destroy
      
      respond_to do |format|
        format.html { redirect_to @chart }
        format.js
      end
    end


    private
    
    def person_params
      params.require(:person).permit(permitted_person_params)
    end
    

    def permitted_person_params
      [:first_name, :last_name, :occupation]
    end
    

    def create_people(company)
      params[:create_instances].each do |pair|
        person_params = ActionController::Parameters.new(pair.last)
        person        = Person.new person_params.permit(permitted_person_params)
        company.people << person
      end if params[:create_instances]
    end
    

    def update_people(company)
      params[:update_instances].each do |pair|
        person_params = ActionController::Parameters.new(pair.last)
        person        = company.people.find(person_params[:uuid])
        person.update! person_params.permit(permitted_person_params)
      end if params[:update_instances]
    end
    

    def delete_people(company)
      params[:delete_instances].each do |uuid|
        company.people.find(uuid).destroy rescue nil
      end if params[:delete_instances]
    end

  end
end
