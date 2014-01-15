Passport.configure do |config|
  config.model :user, strategies: [:rememberable, :password], extensions: [:confirmable]
end
