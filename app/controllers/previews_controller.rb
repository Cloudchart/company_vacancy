class PreviewsController < ApplicationController

  skip_before_filter :check_browser

  layout 'preview'


  def company
    @company = Company.find(params[:id])
    respond(@company)
  end


  def insight
    @pin = Pin.find(params[:id])
    respond(@pin)
  end


  def pinboard
    @pinboard = Pinboard.find(params[:id])
    respond(@pinboard)
  end


  def user
    @user = User.friendly.find(params[:id])
    respond(@user)
  end


  private


  def respond(record)
    respond_to do |format|
      format.html
      format.png {
        render_or_generate_preview(record)
      }
    end
  end

  def render_or_generate_preview(record)
    record = record.parent if record.class == Pin && record.parent_id.present?

    if record.preview_stored?
      send_data record.preview.data, type: :png, disposition: :inline
    else
      PreviewWorker.perform_async(record.class.name, record.id)
      render nothing: true
    end
  end


end
