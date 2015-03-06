class RolesController < ApplicationController
  load_and_authorize_resource

  def update
    @role.update!(role_params)

    respond_to do |format|
      format.json { render json: @role }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: :fail, status: 422 }
    end
  end

  def destroy
    if @role.value.to_s == Company::ROLES.first.to_s
      render json: { errors: { base: 'owner' } }, status: 422
    else
      @role.destroy
      render json: {}
    end
  end

private

  def role_params
    params.require(:role).permit(:value)
  end

end
