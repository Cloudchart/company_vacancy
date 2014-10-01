class PicturesController < ApplicationController
  

  def create
    block   = Block.includes(block_identities: :identity).find(params[:block_id])
    picture = Picture.new(resource_params)

    block.block_identities.each(&:skip_reposition!)
    block.block_identities.destroy_all

    block.pictures << picture
    
    respond_to do |format|
      format.json do
        render json: {
          picture:  picture.active_model_serializer.new(picture),
          block:    block.active_model_serializer.new(block)
        }
      end
    end
  end
  
  
  def update
    block   = Block.includes(:pictures).find(params[:block_id])
    picture = block.pictures.first
    
    picture.update!(resource_params)
    
    respond_to do |format|
      format.json do
        render json: {
          picture:  picture.active_model_serializer.new(picture),
          block:    block.active_model_serializer.new(block)
        }
      end
    end
    
  end


  private
  
  
  def resource_params
    params.require(:picture).permit(:image)
  end
  

end
