CloudOAuth.configure do |config|

  %w(facebook linkedin twitter).each do |provider_name|
    config.send(provider_name) do |provider|
      provider.client_id = ENV["#{provider_name.upcase}_KEY"]
      provider.client_secret = ENV["#{provider_name.upcase}_SECRET"]
    end
  end

end
