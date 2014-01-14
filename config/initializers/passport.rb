Passport.configure do |config|
  config.model :user, strategies: [:rememberable, :password], extensions: [:confirmable]
end

# warden
Rails.application.config.app_middleware.use Warden::Manager do |manager|
  Passport.warden_config = manager
  Passport.configure_warden!
end

Warden::Strategies.add(:password, Passport::Strategies::Password)
Warden::Strategies.add(:rememberable, Passport::Strategies::Rememberable)

Warden::Manager.after_authentication do |user, auth, opts|
  # confirmable
  model = Passport::Model.find_model(user)
  if model.try(:extensions) && model.extensions[model.extensions.index(:confirmable)]
    scope = opts[:scope]
    token = user.tokens.where(name: :confirmation).first
    
    if token
      auth.logout(scope)
      throw(:warden, scope: scope, message: I18n.t('messages.unconfirmed_account'))      
    end
  end

  # rememberable
  if auth.params[:remember_me].present?
    auth.cookies.signed[:user_id] = {
      value: user.id,
      expires: 2.weeks.from_now
    }
  end
end

Warden::Manager.before_logout do |user, auth, opts|
  auth.cookies.delete(:user_id)
end

# helpers
ActiveRecord::Base.extend Passport::Helpers::Model

ActiveSupport.on_load(:action_controller) do
  include Passport::Helpers::Controller
end
