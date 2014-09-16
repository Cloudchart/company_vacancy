module Companies
  class AccessRightsController < ApplicationController

    def index
      @company = Company.find(params[:company_id])
      
      respond_to do |format|
        format.html
        format.json { render json: { company: CompanySerializer.new(@company) } }
      end
    end

    def create
    end

    def update
    end

    def destroy
    end

  end
end
