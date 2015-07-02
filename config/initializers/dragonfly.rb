require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  verify_urls true
  secret "e3abcde82d70489133c44e2d5f4d20f26a61de6256fc0ad51358ae5671142819"

  url_format "/media/:job/:name"

  if %(staging production).include?(Rails.env)
    url_host ENV['ASSET_HOST']
  else
    url_host "http://#{ENV['APP_HOST']}"
  end

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
