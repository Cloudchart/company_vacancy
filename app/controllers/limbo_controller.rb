class LimboController < ApplicationController

  def index
    authorize! :access, :limbo

    respond_to do |format|
      format.html
    end
  end

end
