Passport.configure do |config|
  config.model :user,
    strategies: [:rememberable, :password_authenticatable], extensions: [:confirmable]
end
