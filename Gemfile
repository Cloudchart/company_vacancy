source 'https://rubygems.org'

# ruby '2.1.1'

gem 'rails', '~> 4.1.0'
gem 'mysql2'

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '~> 2.5.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'bourbon'
gem 'font-awesome-rails'
gem 'carrierwave'
gem 'carrierwave-meta'
gem 'mini_magick'
gem 'simple_form'
gem 'bcrypt', '~> 3.1.7'
gem 'oauth2'
gem 'active_attr'
gem 'cancan'
gem 'puma'
gem 'tire'
gem 'rails_admin'
gem 'warden'
gem 'country_select'
gem 'kaminari'
gem 'paper_trail' # tracks changes to model's data
gem 'impressionist' # tracks page views
gem 'dotenv-rails' # loads environment variables from .env
gem 'sidekiq' # background processing using redis

gem 'pagescript', git: 'git@github.com:Cloudchart/pagescript.git'

# CloudProfile Engine
#
gem 'cloud_profile', path: 'vendor/engines/cloud_profile'

# CloudBlueprint Engine
#
gem 'cloud_blueprint', path: 'vendor/engines/cloud_blueprint'

# CloudOAuth Gem
#
gem 'cloud_oauth', path: 'vendor/gems/cloud_oauth'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'awesome_print' # styled print for ruby objects in rails console
  gem 'quiet_assets' # mutes assets pipeline log messages
  gem 'letter_opener' # preview mail in the browser instead of sending
  gem 'capistrano', '~> 3.2.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rbenv'
  gem 'capistrano3-puma'
  gem 'capistrano-sidekiq'
end

group :development, :test do
  gem 'factory_girl_rails' # fixtures replacement
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
end

group :production, :staging, :beta do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby
  gem 'postmark-rails'
end

# Use debugger
# gem 'debugger', group: [:development, :test]
