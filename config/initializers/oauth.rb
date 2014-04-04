CloudOAuth.configure do |config|
  
  config.facebook do |fb|
    fb.client_id      = ENV['FACEBOOK_KEY']
    fb.client_secret  = ENV['FACEBOOK_SECRET']
  end
  
  config.linkedin do |ln|
    ln.client_id      = ENV['LINKEDIN_KEY']
    ln.client_secret  = ENV['LINKEDIN_SECRET']
  end
  
end
