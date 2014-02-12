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
  
end
