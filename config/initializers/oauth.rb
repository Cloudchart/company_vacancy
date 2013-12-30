Cloudchart::OAuth.configure do |config|
  config.provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
end
