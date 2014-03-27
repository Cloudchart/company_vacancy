#Cloudchart::OAuth.configure do |config|
#  config.provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
#  config.provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
#end


CloudOAuth.configure do |config|
  
  config.facebook do |fb|
    fb.client_id      = ENV['FACEBOOK_KEY']
    fb.client_secret  = ENV['FACEBOOK_SECRET']
  end
  
end
