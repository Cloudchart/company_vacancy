class LimboController < ApplicationController

  def index
    authorize! :access, :limbo

    @pins = Pin.limbo

    respond_to do |format|
      format.html
      format.json
    end
  end

end
