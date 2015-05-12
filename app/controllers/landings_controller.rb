class LandingsController < ApplicationController

  # load_and_authorize_resource

  def index
    # get all landings for user
  end

  def create
  end

  def update
  end

  def destroy
  end

private

  def default_landing_params
    params.require(:landing).permit(:title, :image, :body)
  end

  def landing_params_for_create
    params = default_landing_params
    params << :user_id
    params
  end

  def landing_params_for_update
    default_landing_params
  end

end
