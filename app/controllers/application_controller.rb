class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :store_location
  
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to main_app.root_path, alert: exception.message
    else
      redirect_to cloud_profile.login_path
    end
  end
  
  def authenticate(options = {})
    warden.authenticate(options)
  end

  def authenticate_user(options = {})
    options[:scope] = :user
    authenticate(options)
  end

  def decorate(object, klass=nil)
    klass ||= "#{object.class}Decorator".constantize
    decorator = klass.new(object)
  end
  
private

  def store_location
    return unless request.get? && !current_user.present?

    if !request.xhr? && 
        request.path != cloud_profile.login_path &&
        request.path != cloud_profile.register_path
      session[:previous_path] = request.fullpath 
    end
  end
end
