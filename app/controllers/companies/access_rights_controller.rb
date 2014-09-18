module Companies
  class AccessRightsController < ApplicationController

    def index
      @company = Company.find(params[:company_id])
      
      respond_to do |format|
        format.html
        format.json { render json: { users: @company.users, access_rights: @company.access_rights } }
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
