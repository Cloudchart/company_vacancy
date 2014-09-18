module Companies
  class AccessRightsController < ApplicationController

    # List
    #
    def index
      @company = Company.find(params[:company_id])
      authorize! :manage_company_access_rights, @company
      
      respond_to do |format|
        format.html
        format.json do
          render json: {
            users:  ActiveModel::ArraySerializer.new(@company.users.includes(:emails)),
            roles:  ActiveModel::ArraySerializer.new(@company.roles)
          }
        end
      end
    end

    # Destroy
    #
    def destroy
      role = Role.find(params[:id])
      authorize! :manage_company_access_rights, role.owner
      
      if role.value.to_s == Company::ROLES.first.to_s
        render json: { errors: { base: 'owner' } }, status: 422
      else
        role.destroy
        render json: {}
      end
    end

  end
end
