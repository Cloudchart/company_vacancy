class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

    def present(object, klass = nil)
      klass ||= "#{object.class}Presenter".constantize
      klass.new(object, view_context)
    end

end
