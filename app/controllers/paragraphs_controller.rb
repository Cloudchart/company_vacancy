class ParagraphsController < ApplicationController


  before_action :find_owner
  

  def update
    @owner.paragraph or @owner.build_paragraph

    @owner.paragraph.update!(resource_params)
    
    respond_to do |format|
      format.json { render json: @owner.paragraph, root: :paragraph }
    end
  end
  
  
  def destroy
    @owner.paragraph.destroy
    
    respond_to do |format|
      format.json { render json: @owner.paragraph, root: :paragraph }
    end
  end


  private
  
  
  def find_owner
    @owner = begin
      case params[:type]
        when :block
          Block.where(identity_type: Paragraph.name).includes(:paragraph).find(params[:block_id])
      end
    end
  end
  
  
  def resource_params
    params.require(:paragraph).permit(:content)
  end
  

end
