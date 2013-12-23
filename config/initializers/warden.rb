Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.default_scope = :user
  manager.failure_app = lambda { |env| SessionsController.action(:new).call(env) }
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

# Warden::Strategies.add(:password) do
#   def valid?
#     params['email'] && params['password']
#   end
  
#   def authenticate!
#     user = User.find_by(email: params['email'])
#     if user && user.authenticate(params['password'])
#       success! user
#     else
#       fail I18n.t('messages.invalid_email_or_password')
#     end
#   end
# end
