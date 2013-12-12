class TextsController < ApplicationController
  # POST /texts
  def create
    @text = Text.new(text_params)

    if @text.save
      redirect_to edit_company_path(@text.company), notice: 'Text block successfully created.'
    else
      redirect_to edit_company_path(@text.company)
    end
  end

  def update
  end

  def destroy
  end

  private
    # Only allow a trusted parameter "white list" through.
    def text_params
      params.require(:text).permit(:content, block_attributes: [:title, :position, :owner_id, :owner_type])
    end
end
