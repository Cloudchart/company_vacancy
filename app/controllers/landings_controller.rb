class LandingsController < ApplicationController

  before_filter :set_user, only: :create
  before_filter :set_landing, only: [:create, :show, :update, :destroy]

  load_and_authorize_resource

  before_filter :check_existing_landing, only: :create

  def show
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @landing.author = current_user

    if @landing.save
      respond_to do |format|
        format.json { render json: { id: @landing.id } }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @landing.errors }, status: 422 }
      end
    end
  end

  def update
    if @landing.update(landing_params)
      respond_to do |format|
        format.json { render json: { id: @landing.id } }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @landing.errors }, status: 422 }
      end
    end
  end

  def destroy
    @landing.destroy

    respond_to do |format|
      format.json { render json: { id: @landing.id } }
    end
  end

private

  def set_user
    @user = User.friendly.find(params[:user_id])
  end

  def set_landing
    @landing = if action_name == 'create'
      @user.landings.build
    else
      Landing.friendly.find(params[:id])
    end
  end

  def landing_params
    params.require(:landing).permit(:title, :image, :body)
  end

  def check_existing_landing
    if existing_landing = @user.landings.find_by(author: current_user)
      respond_to do |format|
        format.json { render json: { id: existing_landing.id } }
      end and return
    end
  end

end
