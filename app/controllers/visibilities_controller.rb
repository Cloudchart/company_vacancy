class VisibilitiesController < ApplicationController  

  before_action :set_visibility, only: :update
  before_action :set_owner, only: :create

  authorize_resource

  def create
    @visibility = @owner.visibilities.build(visibility_params)

    if @visibility.save
      if @owner.instance_of?(Post)
        Activity.track(current_user, params[:action], @owner, @owner.company)
      end

      respond_to do |format|
        format.json { render json: @visibility }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def update
    if @visibility.update(visibility_params)
      respond_to do |format|
        format.json { render json: @visibility }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

private

  def visibility_params
    params.require(:visibility).permit(:value, :attribute_name)
  end

  def set_visibility
    @visibility = Visibility.find(params[:id])
  end

  def set_owner
    @owner = case params[:type]
    when :post
      Post.find(params[:post_id])
    end
  end
  
end
