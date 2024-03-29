module CloudOAuth
  
  class Base


    # Configuration
    #
    def self.config
      @config ||= OpenStruct.new
    end
    
    def config
      self.class.config
    end


    INITIALIZE_OPTIONS    = [:site, :authorize_url, :token_url, :token_method]


    def authorize_url(params = {})
      strategy.authorize_url(params.merge(scope: config.scope))
    end
    

    def get_token(code, params = {}, options = {})
      strategy.get_token(code, params, options)
    end
    

    def request(verb, url, options = {})
      client.request(verb, url, options)
    end


  protected
  

    def token(oauth_access_token, options = {})
      OAuth2::AccessToken.from_hash(client, options.merge(access_token: oauth_access_token))
    end
  

    def strategy
      @strategy ||= client.auth_code
    end
  
    
    def client
      @client ||= OAuth2::Client.new(config.client_id, config.client_secret, config.to_h.select { |key| INITIALIZE_OPTIONS.include?(key) })
    end


  end
  
end
