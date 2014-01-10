Passport.configure do |config|
  config.model :user, strategies: [:password]
end

Rails.application.config.app_middleware.use Warden::Manager do |manager|
  Passport.warden_config = manager
  Passport.configure_warden!
end

Warden::Strategies.add(:password, Passport::Strategies::Password)

ActiveRecord::Base.extend Passport::Helpers::Model

ActiveSupport.on_load(:action_controller) do
  include Passport::Helpers::Controller
end
