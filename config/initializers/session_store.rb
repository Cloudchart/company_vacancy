# Be sure to restart your server when you modify this file.

if ENV['REDIS_CACHE_URL'].present?
  Cloudchart::Application.config.session_store :redis_store, { redis_server: ENV['REDIS_CACHE_URL'] }
else
  Cloudchart::Application.config.session_store :cookie_store, key: '_cloudchart_session'
end
