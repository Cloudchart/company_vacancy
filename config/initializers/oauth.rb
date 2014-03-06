Cloudchart::OAuth.configure do |config|
  config.provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  config.provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
end
