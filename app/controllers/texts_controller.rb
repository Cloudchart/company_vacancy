class TextsController < ApplicationController
  before_action :set_text, only: [:update, :destroy]

  # GET /texts/new
  def new
    @text = Text.new
    @text.build_block.owner = Company.find(params[:company_id])
  end

  # POST /texts
  def create
    @text = Text.new(text_params)

    if @text.save
      redirect_to edit_company_path(@text.company), notice: 'Text block successfully created.'
    else
      redirect_to edit_company_path(@text.company)
    end
  end

  # PATCH/PUT /texts/1
  def update
    if @text.update(text_params)
      redirect_to edit_company_path(@text.company), notice: 'Text block successfully created.'
    else
      redirect_to edit_company_path(@text.company)
    end    
  end

  # DELETE /texts/1
  def destroy
    @text.destroy
    redirect_to companies_url, notice: 'Text block was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_text
      @text = Text.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def text_params
      params.require(:text).permit(:content, block_attributes: [:kind, :position, :owner_id, :owner_type])
    end
end
