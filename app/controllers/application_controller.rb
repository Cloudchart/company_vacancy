class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
  def authenticate(options = {})
    warden.authenticate(options)
  end
  
  def authenticate_user(options = {})
    options[:scope] = :user
    authenticate(options)
  end
  

end
