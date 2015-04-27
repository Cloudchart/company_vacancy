class ErrorsController < ApplicationController
  def not_found
    render status: 404, layout: (user_authenticated? ? 'application' : 'guest')
  end

  def internal_error
    render status: 500, layout: (user_authenticated? ? 'application' : 'guest')
  end
end
