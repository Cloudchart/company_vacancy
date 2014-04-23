class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    if request.env["HTTP_REFERER"].present?
      redirect_to :back, alert: exception.message
    else
      redirect_to :root, alert: exception.message
    end
  end
  
  def authenticate(options = {})
    warden.authenticate(options)
  end

  def authenticate_user(options = {})
    options[:scope] = :user
    authenticate(options)
  end

end
