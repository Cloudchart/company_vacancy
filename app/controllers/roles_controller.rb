class RolesController < ApplicationController
  before_filter :set_role

  load_and_authorize_resource

  def create
    @role.author = current_user

    if params[:twitter].present?
      user = User.new(twitter: params[:twitter])
      user = User.friendly.find(user.twitter) unless user.valid?
      @role.user = user
    end

    @role.save!

    Activity.track(current_user, 'invite', @role.owner, data: {
      user_id: @role.user.id
    })

    if params[:email]
      UserMailer.entity_invite(@role, params[:email]).deliver
      Activity.track(current_user, 'email_invite', @role.owner, data: {
        user_id: @role.user.id
      })
    end

    respond_to do |format|
      format.json { render json: { id: @role.id } }
    end

  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: { errors: @role.errors }, status: 422 }
    end
  end


  def accept
    if @role.user == current_user
      @role.accept!
    else
      raise ActiveRecord::RecordNotFound
    end

    Activity.track(current_user, 'accept_invite', @role.owner, data: {
      author_id: @role.author.try(:id)
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
        author_id: @role.author.try(:id)
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
    @role = if action_name == 'create'
      Role.new(role_create_params)
    else
      Role.find(params[:id])
    end
  end

end
