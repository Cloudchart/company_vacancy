require 'cloud_oauth/base'

module CloudOAuth

  class Twitter < Base

    config.site = 'https://api.twitter.com'
    config.token_url = '/oauth2/token'

    attr_accessor :access_token

    def initialize(access_token=nil)
      @access_token = access_token
    end

    def friends(screen_name, options={})
      token.get('/1.1/friends/list.json', params: options.merge(screen_name: screen_name)).parsed
    end

    def get_token
      client.client_credentials.get_token
    end

    def token
      @token ||= if @access_token
        OAuth2::AccessToken.from_hash(client, access_token: @access_token)
      else
        get_token
      end
    end

  end
end
