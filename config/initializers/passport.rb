require 'warden'

#Passport.configure do |config|
  #config.model :user,
  #  strategies: [:rememberable, :password_authenticatable], extensions: [:confirmable]
#end

Rails.configuration.middleware.use Warden::Manager do |manager|
end


module HelperMethods

  def warden
    request.env['warden']
  end


  def current_user
    warden.user(:user)
  end

  def user_authenticated?
    warden.authenticated?(:user)
  end


  def current_social_network
    warden.user(:social_network)
  end


  def social_network_authenticated?
    warden.authenticated?(:social_network)
  end


end

module Warden::Mixins::Common
  
  def request
    @request ||= ActionDispatch::Request.new(env)
  end
  
  def response
    @response ||= request.response
  end
  
  def cookies
    request.cookie_jar
  end
  
  def raw_session
    request.session
  end
  
  def reset_session!
    raw_session.inspect
    raw_session.clear
  end
  
end


class Warden::SessionSerializer
  
  def serialize(record)
    [record.class.name, record.to_param]
  end
  
  def deserialize(params)
    class_name, id = params
    class_name.to_s.classify.constantize.find(id)
  end
  
end


ActiveSupport.on_load(:action_controller) do
  include HelperMethods
end

ActiveSupport.on_load(:action_view) do
  include HelperMethods
end
