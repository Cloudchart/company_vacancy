class LandingsController < ApplicationController

  before_filter :set_user, only: [:create]
  before_filter :set_landing, only: [:create, :show, :update, :destroy]

  load_and_authorize_resource

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
      @user.landings.build(landing_params)
    else
      Landing.friendly.find(params[:id])
    end
  end

  def landing_params
    params.permit(:landing).permit(:title, :image, :body)
  end

end
