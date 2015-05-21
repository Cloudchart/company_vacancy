class RolesController < ApplicationController
  load_and_authorize_resource



  def create
    @role         = Role.build(role_create_params)
    @role.author  = current_user

    if params[:twitter]
      @role.user = User.find_or_initialize_by(twitter: params[:twitter])
    end

    @role.save!

    if params[:email]
      # TODO: send email
    end

    respond_to do |format|
      format.json { render json: { id: @role.id } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: { errors: @role.errors }, status: 402 }
    end
  end


  def accept
    @role = Role.find(params[:id])
    if @role.user == current_user
      @role.accept!
    else
      raise ActiveRecord::RecordNotFound
    end

    respond_to do |format|
      format.json { render json: { id: @role.id } }
    end

  rescue ActiveRecord::RecordNotFound

    respond_to do |format|
      format.json { render json: {}, status: 404 }
    end

  end



  def update
    @role.update!(role_update_params)

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

  def role_create_params
    params.require(:role).permit(:user_id, :value, :owner_id, :owner_type)
  end

  def role_update_params
    params.require(:role).permit(:value)
  end

end
