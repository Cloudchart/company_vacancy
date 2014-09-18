module Companies
  class AccessRightsController < ApplicationController

    
    # List
    #
    def index
      @company = Company.find(params[:company_id])
      
      respond_to do |format|
        format.html
        format.json do
          render json: {
            users:          ActiveModel::ArraySerializer.new(@company.users.includes(:emails)),
            access_rights:  ActiveModel::ArraySerializer.new(@company.access_rights)
          }
        end
      end
    end


    # Destroy
    #
    def destroy
      role = Company::AccessRight.find(params[:id])
      
      if role.role.to_s == Company::ROLES.first.to_s
        render json: { errors: { base: 'owner' } }, status: 422
      else
        role.destroy
        render json: {}
      end
    end


  end
end
