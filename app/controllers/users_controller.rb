class UsersController < ApplicationController
  include FollowableController

  load_and_authorize_resource
  
  def show
    respond_to do |format|
      format.html
    end
  end

  def update
    @user.should_validate_name!
    @user.update! params_for_update

    respond_to do |format|
      format.json { render json: { id: @user.uuid } }
    end
  
  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: { errors: @user.errors }, status: 422 }
    end
  end

  def settings 
    respond_to do |format|
      format.html
    end
  end

private

  def params_for_update
    params.require(:user).permit(:full_name, :avatar, :remove_avatar, :occupation, :company)
  end

end
