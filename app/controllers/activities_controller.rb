class ActivitiesController < ApplicationController

  def create
    @activity = current_user.activities.build(activity_params)
    authorize! :create, @activity
    @activity.should_validate_action!

    if @activity.save
      respond_to do |format|
        format.json { render json: @activity }
      end
    else
      respond_to do |format|
        format.json { render json: @activity, status: 422 }
      end
    end
  end

private

  def activity_params
    params.require(:activity).permit(:action, :trackable_id, :trackable_type)
  end

end
