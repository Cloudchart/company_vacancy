class UsersController < ApplicationController
  include FollowableController

  before_filter :set_user, only: [:show, :update, :settings]

  authorize_resource except: [:finish_tour]
  
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

  def finish_tour
    current_user.tokens.find_by(name: :tour).try(:destroy)

    respond_to do |format|
      format.json { render json: :ok }
    end
  end

private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def params_for_update
    params.require(:user).permit(:full_name, :avatar, :remove_avatar, :occupation, :company)
  end

end
