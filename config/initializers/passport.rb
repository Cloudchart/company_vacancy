require 'warden'

Rails.configuration.middleware.use Warden::Manager do |manager|
end

module HelperMethods

  def warden
    request.env['warden']
  end

  def current_user
    warden.user(:user) ||
      warden.set_user(user_from_cookie, scope: :user) ||
      warden.set_user(guest_user, scope: :user)
  end

  def guest_user
    raise "Couldn't find guest user. Please run rake db:seed." unless
      guest_user = Role.find_by(value: :guest).try(:user)

    guest_user
  end

  def user_from_cookie
    User.find_by(uuid: cookies.signed[:user_id])
  end

  def user_authenticated?
    warden.authenticated?(:user) && !warden.user(:user).guest?
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
    class_name = class_name.to_s.classify

    case class_name
    when 'User'
      class_name.constantize.includes(:roles).find(id)
    else
      class_name.constantize.find(id)
    end rescue nil
  end
  
end

ActiveSupport.on_load(:action_controller) do
  include HelperMethods
end

ActiveSupport.on_load(:action_view) do
  include HelperMethods
end
