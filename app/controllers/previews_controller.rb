class PreviewsController < ApplicationController

  skip_before_filter :check_browser

  layout 'preview'


  def company
    @company = Company.find(params[:id])
  end


  def pinboard
    @pinboard = Pinboard.find(params[:id])
    respond_to do |format|
      format.html
      format.png {
        render_or_generate_preview(@pinboard)
      }
    end
  end


  private

  def render_or_generate_preview(record)
    if record.preview_stored?
      send_data record.preview.data, type: :png, disposition: :inline
    else
      PreviewWorker.perform_async(record.class.name, record.id)
      render nothing: true
    end
  end


end
