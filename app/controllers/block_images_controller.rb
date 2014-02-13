class BlockImagesController < ApplicationController

  def create
    @block_image = BlockImage.new params.require(:block_image).permit(:image, :block_id)
    @block_image.save!
  rescue ActiveRecord::RecordInvalid
  ensure
    redirect_to @block_image.block.owner if @block_image.block.present?    
  end

  def update
    @block_image = BlockImage.find params[:id]
    @block_image.update_attributes! params.require(:block_image).permit(:image)
  rescue ActiveRecord::RecordInvalid
  ensure
    redirect_to @block_image.block.owner if @block_image.block.present?
  end  

end
