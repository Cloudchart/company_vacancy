require 'cloud_oauth/base'

module CloudOAuth

  class Twitter < Base

    config.site = 'https://api.twitter.com'
    config.token_url = '/oauth2/token'

    def friends(twitter)
      token = get_token
      response = token.get('/1.1/friends/list.json', params: { screen_name: twitter.to_s })
      response.parsed
    end

    def get_token(params = {}, options = {})
      client.client_credentials.get_token
    end

  end
end
