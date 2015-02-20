class ParagraphsController < ApplicationController
  before_action :find_owner
  before_action :set_paragraph

  load_and_authorize_resource

  def create
    if @paragraph.save
      respond_to do |format|
        format.json { render json: @paragraph }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def update
    if @paragraph.update(paragraph_params)
      respond_to do |format|
        format.json { render json: @paragraph }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end
  
  def destroy
    @paragraph.destroy
    
    respond_to do |format|
      format.json { render json: @paragraph }
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

  def set_paragraph
    @paragraph = if action_name == 'create'
      @owner.build_paragraph(paragraph_params)
    else
      @owner.paragraph
    end
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:content)
  end

end
