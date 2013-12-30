module Cloudchart
  module OAuth
    PROVIDERS_DEFAULTS = {
      facebook: {
        site: 'https://graph.facebook.com/oauth',
        token_url: '/oauth/access_token'
      }
    }

    mattr_reader :clients
    @@clients = {}

    def self.configure(&block)
      yield self if block_given?
    end

    def self.provider(provider, key, secret)
      provider = provider.to_sym
      @@clients[provider] = OAuth2::Client.new(key, secret, PROVIDERS_DEFAULTS[provider])
    end

    def self.authorize_url(provider, options={})
      provider = provider.to_sym
      @@clients[provider].send("#{provider == :facebook ? 'facebook_' : ''}auth_code").authorize_url(options)
    end

    def self.get_token(provider, code, options={})
      provider = provider.to_sym
      @@clients[provider].send("#{provider == :facebook ? 'facebook_' : ''}auth_code").get_token(code, options)
    end
    
  end
  
end
