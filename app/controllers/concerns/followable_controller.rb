module FollowableController
  extend ActiveSupport::Concern

  included do
    after_action :create_follow_intercom_event, only: [:follow, :unfollow]
  end

  def follow
    @object = controller_name.classify.constantize.find(params[:id])
    @object.followers.find_or_create_by(user: current_user)

    respond_to do |format|
      format.json { render json: @object.active_model_serializer.new(@object, scope: current_user) }
    end
  end

  def unfollow
    @object = controller_name.classify.constantize.find(params[:id])
    current_user.favorites.find_by(favoritable: @object).try(:delete)

    respond_to do |format|
      format.json { render json: @object.active_model_serializer.new(@object, scope: current_user) }
    end
  end

private

  def create_follow_intercom_event
    return unless should_perform_sidekiq_worker? && @object
    object_name = @object.class.name.underscore
    IntercomEventsWorker.perform_async("#{action_name}ed-#{object_name}", current_user.id, "#{object_name}_id" => @object.id)
  end
  
end
