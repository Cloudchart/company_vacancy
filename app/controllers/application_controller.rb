class ApplicationController < ActionController::Base
  include RailsAdminConfigReload
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_browser
  before_filter :store_location

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: 404, layout: false }
      format.json { render json: { message: exception.message }, status: 404 }
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

    if request.path != main_app.old_browsers_path && cookies[:agree_to_browse].nil? && 
        Cloudchart::BROWSERS_WHITELIST.detect { |browser| user_agent < browser }
      redirect_to main_app.old_browsers_path
    end
  end

  def store_location
    return if user_authenticated? || !request.get? || request.xhr? || main_app.old_browsers_path
    session[:previous_path] = request.fullpath
  end
  
end
