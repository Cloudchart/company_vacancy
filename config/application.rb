require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Cloudchart
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # locales
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')] # global variables
    config.i18n.load_path += Dir[Rails.root.join('locales', '**', '*.{rb,yml}')] # translations
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # lib
    config.autoload_paths += %W(#{config.root}/lib/cloudchart)

    # postmark
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_key: ENV['POSTMARK_API_KEY'] }

  end
end
