module CloudOAuth
  
  class Base

    # Configuration
    #
    cattr_accessor :config
    @@config = OpenStruct.new

    INITIALIZE_OPTIONS    = [:site, :authorize_url, :token_url, :token_method]


    delegate :authorize_url, :get_token, to: :strategy


  protected
  

    def strategy
      @strategy ||= client.auth_code
    end
  
    
    def client
      @client ||= OAuth2::Client.new(config.client_id, config.client_secret, config.to_h.select { |key| INITIALIZE_OPTIONS.include?(key) })
    end

  end
  
end
