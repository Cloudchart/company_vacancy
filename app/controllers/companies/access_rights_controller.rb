module Companies
  class AccessRightsController < ApplicationController

    # List
    #
    def index
      @company = Company.find(params[:company_id])
      authorize! :list_company_access_rights, @company
      
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

  end
end
