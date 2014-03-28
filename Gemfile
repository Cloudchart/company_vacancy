source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.4'
gem 'mysql2'

gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'bourbon'
gem 'font-awesome-rails'
gem 'carrierwave'
gem 'carrierwave-meta'
gem 'mini_magick'
gem 'simple_form'
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'oauth2'
gem 'postmark-rails', '~> 0.5.2'
gem 'active_attr'
gem 'cancan'
gem 'tire'
gem 'puma'
gem 'rails_admin'
gem 'paper_trail', '~> 3.0.1'
gem 'country_select'

# gem 'passport', path: '~/code/passport'
gem 'passport', git: 'git@github.com:Cloudchart/passport.git'
# gem 'pagescript', path: '~/code/pagescript'
gem 'pagescript', git: 'git@github.com:Cloudchart/pagescript.git'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'awesome_print' # styled print for ruby objects in rails console
  gem 'quiet_assets' # mutes assets pipeline log messages
  gem 'letter_opener' # preview mail in the browser instead of sending
  gem 'bullet' # helps to kill N+1 queries and unused eager loading
end

group :development, :test do
  gem 'dotenv-rails' # loads environment variables from .env
  gem 'factory_girl_rails' # fixtures replacement
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
end

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
