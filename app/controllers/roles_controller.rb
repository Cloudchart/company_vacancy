class RolesController < ApplicationController
  before_filter :set_role, except: :create

  # authorize_resource except: :create

  def create
    @role         = Role.new(role_create_params)
    @role.author  = current_user

    if params[:twitter]
      @role.user = User.find_or_initialize_by(twitter: params[:twitter])
    end

    @role.save!

    Activity.track(current_user, 'invite', @role.owner, data: {
      user_id: @role.user.uuid
    })

    if params[:email]
      UserMailer.entity_invite(@role, params[:email]).deliver
      Activity.track(current_user, 'email_invite', @role.owner, data: {
        user_id: @role.user.uuid
      })
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

    Activity.track(current_user, 'accept_invite', @role.owner, data: {
      author_id: @role.author.id
    })

    respond_to do |format|
      format.json { render json: { id: @role.id } }
    end

  rescue ActiveRecord::RecordNotFound

    respond_to do |format|
      format.json { render json: {}, status: 404 }
    end

  end

  def show
    respond_to do |format|
      format.json
    end
  end

  def update
    @role.update!(role_update_params)

    respond_to do |format|
      format.json { render json: { id: @role.id } }
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
      Activity.track(current_user, 'decline_invite', @role.owner, data: {
        author_id: @role.author.id
      })

      render json: { id: @role.id }
    end
  end

private

  def role_create_params
    params.require(:role).permit(:user_id, :value, :owner_id, :owner_type)
  end

  def role_update_params
    params.require(:role).permit(:value)
  end

  def set_role
    @role = Role.find(params[:id])
  end

end
