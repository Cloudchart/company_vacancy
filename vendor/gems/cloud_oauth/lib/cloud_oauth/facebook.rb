require 'cloud_oauth/base'

module CloudOAuth

  class Facebook < Base

    config.site       = 'https://graph.facebook.com'
    config.token_url  = '/oauth/access_token'
    
    
    def get_token(code, params = {}, options = {})
      super(code, params.merge(parse: :query), options)
    end
    
    
  end

end
