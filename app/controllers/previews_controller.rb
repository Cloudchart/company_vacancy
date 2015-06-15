class PreviewsController < ApplicationController

  layout 'preview'


  def company
    @company = Company.find(params[:id])
  end


  def pinboard
    @pinboard = Pinboard.find(params[:id])
    respond_to do |format|
      format.html
    end
  end


end
