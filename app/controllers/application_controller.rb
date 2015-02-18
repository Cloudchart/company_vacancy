class ApplicationController < ActionController::Base
  include RailsAdminConfigReload
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :store_location
  
  rescue_from CanCan::AccessDenied do |exception|
    if user_authenticated?
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

  def should_perform_sidekiq_worker?
    %(staging production).include?(Rails.env)
  end
  
private

  def store_location
    return if user_authenticated? || !request.get? || request.xhr? ||
      "#{controller_name}##{action_name}" =~ /authentications#new|users#new|passwords#reset/

    session[:previous_path] = request.fullpath
  end
  
end
