module FollowableController
  extend ActiveSupport::Concern

  def follow
    object = controller_name.classify.constantize.find(params[:id])

    if current_user.favorites.pluck(:favoritable_id).include?(object.id)
      respond_to do |format|
        format.json { render json: :fail, status: 412 }
      end
    else
      object.favorites.create(user: current_user)

      respond_to do |format|
        format.json { render json: object.active_model_serializer.new(object, scope: current_user) }
      end
    end
  end

  def unfollow
    object = controller_name.classify.constantize.find(params[:id])

    if current_user.favorites.pluck(:favoritable_id).include?(object.id)
      current_user.favorites.find_by(favoritable: object).delete

      respond_to do |format|
        format.json { render json: object.active_model_serializer.new(object, scope: current_user) }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 412 }
      end
    end
  end  
  
end
