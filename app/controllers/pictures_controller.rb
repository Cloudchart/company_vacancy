class PicturesController < ApplicationController


  before_action :find_owner
  

  def create
    picture = @owner.create_picture!(resource_params)

    respond_to do |format|
      format.json do
        render json: picture, root: :picture
      end
    end
  end
  
  
  def update
    @owner.picture.update!(resource_params)
    
    respond_to do |format|
      format.json { render json: @owner.picture, root: :picture }
    end
  end
  
  
  def destroy
    @owner.picture.destroy
    
    respond_to do |format|
      format.json { render json: @owner.picture, root: :picture }
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
  
  
  def resource_params
    params.require(:picture).permit(:image)
  end
  

end
