class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  #before_action :require_properly_named_user!

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


  def require_authenticated_user!
    redirect_to main_app.root_path unless user_authenticated?
  end
  

  def require_unauthenticated_user!
    redirect_to main_app.root_path if user_authenticated?
  end
  
  
  def require_properly_named_user!
    redirect_to cloud_profile.profile_activation_completion_path if user_authenticated? && !current_user.has_proper_name?
  end


end
