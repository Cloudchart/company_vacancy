class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :require_authenticated_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_path, alert: exception.message
  end
  
  def authenticate(options = {})
    warden.authenticate(options)
  end

  def authenticate_user(options = {})
    options[:scope] = :user
    authenticate(options)
  end

  def require_authenticated_user!
    redirect_to main_app.root_path unless user_authenticated?
  end

end
