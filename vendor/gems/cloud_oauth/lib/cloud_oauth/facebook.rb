require 'cloud_oauth/base'

module CloudOAuth

  class Facebook < Base

    config.site       = 'https://graph.facebook.com'
    config.token_url  = '/oauth/access_token'
    config.scope      = 'basic_info email'
    
    
    def profile(oauth_access_token)
      access_token = token(oauth_access_token)
      data  = access_token.get('/me').parsed.select { |k, v| profile_fields.include?(k) }
      image = access_token.get('/me/picture?redirect=0&width=200&height=200').parsed
      data['picture'] = image['data']['url']
      OpenStruct.new(data)
    end
    

    def friends(oauth_access_token)
      token(oauth_access_token).get('/me/friends').parsed
    end
    

    def get_token(code, params = {}, options = {})
      super(code, params.merge(parse: :query), options)
    end
  
  private
  
    def profile_fields
      ['id', 'first_name', 'last_name', 'link', 'email']
    end
    
    
  end

end
