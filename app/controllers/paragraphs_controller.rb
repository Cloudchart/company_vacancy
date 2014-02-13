class ParagraphsController < ApplicationController
  

  def create
    @paragraph = Paragraph.new params.require(:paragraph).permit(:content, :block_id)
    @paragraph.save!

  rescue ActiveRecord::RecordInvalid
  ensure
    redirect_to @paragraph.block.owner if @paragraph.block.present?
  end
  

  def update
    @paragraph = Paragraph.find params[:id]
    @paragraph.update_attributes! params.require(:paragraph).permit(:content)

  rescue ActiveRecord::RecordInvalid
  ensure
    redirect_to @paragraph.block.owner if @paragraph.block.present?
  end
  
  
  def delete
    @paragraph = Paragraph.includes(block: :owner).find(params[:id])
    @paragraph.destroy
    
    redirect_to @paragraph.block.owner if @paragraph.block.present?
  end

private

  def paragraph_params_on_create
    params.require(:paragraph).permit(:block_id, :content)
  end
  
  def paragraph_params_on_update
    params.require(:paragraph).permit(:content)
  end

end
