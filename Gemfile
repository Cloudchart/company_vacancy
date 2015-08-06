source 'https://rubygems.org'

# ruby '2.1.1'

gem 'rails', '~> 4.1.0'
gem 'mysql2'
gem 'puma'

gem 'sprockets', '~> 3.0'
gem 'sprockets-es6'
gem 'sass-rails', '~> 5.0.0'
gem 'uglifier', '~> 2.5.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'bourbon', '~> 3.0'
gem 'font-awesome-rails'
gem 'mini_magick'
gem 'bcrypt', '~> 3.1.7'
gem 'oauth2'
gem 'active_attr'
gem 'cancancan'
gem 'tire'
gem 'rails_admin', '= 0.6.7'
gem 'warden'
gem 'kaminari'
gem 'paper_trail' # tracks changes to model's data
gem 'impressionist' # tracks page views
gem 'dotenv-rails' # loads environment variables from .env
gem 'sidekiq', '~> 3.4.0' # background processing using redis
gem 'active_model_serializers', '= 0.8.1'
gem 'dragonfly', '~> 1.0'
gem 'sprockets-commonjs', git: 'git@github.com:Cloudchart/sprockets-commonjs.git'
gem 'sprockets-coffee-react'
gem 'redis-rails'
gem 'jbuilder'
gem 'squeel'
gem 'parslet'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'useragent'
gem 'meta-tags', '~> 2.0.0'
gem 'friendly_id', '~> 5.1.0'
gem 'nilify_blanks', '~> 1.2.0'
gem 'libv8', '~> 3.16'
gem 'zeroclipboard-rails'
gem 'yajl-ruby'
gem 'sinatra', require: nil
gem 'paranoia', '~> 2.0'
gem 'diffbot-ruby-client', :git => 'git@github.com:diffbot/diffbot-ruby-client.git'

# Engines
#
gem 'cloud_profile', path: 'vendor/engines/cloud_profile'
gem 'cloud_api', path: 'vendor/engines/cloud_api'

# Cloudchart Gems
#
gem 'pagescript', git: 'git@github.com:Cloudchart/pagescript.git'
gem 'bootstrap-wysihtml5-rails', git: 'git@github.com:Cloudchart/bootstrap-wysihtml5-rails.git'

# Internal Gems
#
gem 'cloud_oauth', path: 'vendor/gems/cloud_oauth'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'unicorn'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry' # An IRB alternative and runtime developer console
  gem 'pry-remote' # pry extension for pow
  gem 'spring' # speeds up development by keeping application running in the background
  gem 'spring-commands-rspec' # implements the rspec command for spring
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
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.0' # fixtures replacement
  gem 'capybara', '~> 2.0'
  gem 'database_cleaner', '~> 1.4'
  gem 'ffaker'
end

group :production, :staging do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby
  gem 'postmark-rails'
  gem 'intercom-rails', '~> 0.2.24'
  gem 'intercom', '~> 2.4.4'
  gem 'airbrake'
end
