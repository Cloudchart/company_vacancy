class PagesController < ApplicationController

  skip_before_action :require_authenticated_user!

  def show
    @page = Page.find(params[:id])
  end

end
