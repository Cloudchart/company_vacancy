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
    config.i18n.load_path += Dir[Rails.root.join('locales', '**', '*.{rb,yml}')] # translations
    I18n.config.enforce_available_locales = true
    # config.i18n.default_locale = :de

    config.autoload_paths += %W(#{config.root}/lib/cloudchart)
    config.autoload_paths += %W(#{config.root}/vendor/engines/*/app/serializers)
    config.autoload_paths += %W(#{config.root}/vendor/engines/*/app/mutations)
    config.autoload_paths += %W(#{config.root}/vendor/engines/*/app/nodes)

    # Handle exceptions
    #
    config.exceptions_app = self.routes
  end
end
