class PagesController < ApplicationController

  before_action :set_page, only: :show
  before_action :call_page_visit_to_slack_channel, only: :show

  def show
    respond_to do |format|
      format.html
    end
  end

private

  def set_page
    @page = Page.find(params[:id])
  end

  def call_page_visit_to_slack_channel
    post_page_visit_to_slack_channel("#{@page.title} page", main_app.page_url(@page))
  end

end
