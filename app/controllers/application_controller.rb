class ApplicationController < ActionController::Base
  include RailsAdminConfigReload
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_browser
  before_filter :store_location

  rescue_from CanCan::AccessDenied do |exception|
    if request.env['HTTP_REFERER'].present?
      redirect_to :back, alert: exception.message
    else
      redirect_to main_app.root_path, alert: exception.message
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

  def check_browser
    user_agent = UserAgent.parse(request.user_agent)

    if "#{controller_name}##{action_name}" != 'errors#old_browsers' && 
        cookies[:agree_to_browse].nil? && 
        Cloudchart::BROWSERS_WHITELIST.detect { |browser| user_agent < browser }
      redirect_to old_browsers_path
    end
  end

  def store_location
    return if user_authenticated? || !request.get? || request.xhr? ||
      "#{controller_name}##{action_name}" =~ /authentications#new|users#new|passwords#reset|errors#old_browsers/

    session[:previous_path] = request.fullpath
  end
  
end
