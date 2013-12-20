Passport.config do |config|
  config.model :user, strategies: [password: { find_by: :email }]
end
