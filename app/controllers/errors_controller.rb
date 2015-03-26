class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def internal_error
    render status: 500
  end

  def old_browsers
    render layout: "old_browsers"
  end
end
