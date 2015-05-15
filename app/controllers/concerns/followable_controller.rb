module FollowableController
  extend ActiveSupport::Concern

  def follow
    object = controller_name.classify.constantize.find(params[:id])
    object.followers.find_or_create_by(user: current_user)

    respond_to do |format|
      format.json { render json: object.active_model_serializer.new(object, scope: current_user) }
    end
  end

  def unfollow
    object = controller_name.classify.constantize.find(params[:id])
    current_user.favorites.find_by(favoritable: object).try(:delete)

    respond_to do |format|
      format.json { render json: object.active_model_serializer.new(object, scope: current_user) }
    end
  end  
  
end
