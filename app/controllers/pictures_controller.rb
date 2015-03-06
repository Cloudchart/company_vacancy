class PicturesController < ApplicationController

  before_action :find_owner
  before_action :set_picture
  
  authorize_resource

  def create
    if @picture.save
      respond_to do |format|
        format.json { render json: @picture, root: :picture }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end

  end
  
  def update
    if @picture.update(picture_params)
      respond_to do |format|
        format.json { render json: @picture, root: :picture }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end
  
  def destroy
    @picture.destroy
    
    respond_to do |format|
      format.json { render json: @picture, root: :picture }
    end
  end

private
  
  def find_owner
    @owner = begin
      case params[:type]
        when :block
          Block.where(identity_type: Picture.name).includes(:picture).find(params[:block_id])
      end
    end
  end

  def set_picture
    @picture = if action_name == 'create'
      @owner.build_picture(picture_params)
    else
      @owner.picture
    end
  end
  
  def picture_params
    params.require(:picture).permit(:image)
  end

end
