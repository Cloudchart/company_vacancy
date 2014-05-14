require 'cloud_oauth/base'

module CloudOAuth

  class Linkedin < Base

    config.site           = 'https://www.linkedin.com'
    config.api_site       = 'https://api.linkedin.com/v1'
    config.authorize_url  = '/uas/oauth2/authorization'
    config.token_url      = '/uas/oauth2/accessToken'
    config.scope          = 'r_basicprofile r_emailaddress r_network'
    config.profile_fields = 'id,first-name,last-name,email-address,public-profile-url'
    
    
    def profile(oauth_access_token)
      access_token = token(oauth_access_token)
      data = access_token.get(config.api_site + "/people/~:(#{config.profile_fields})").parsed['person'].reduce({}) do |memo, pair|
        key             = profile_fields[pair.first.to_sym]
        memo[key.to_s]  = pair.last if key.present?
        memo
      end
      image = access_token.get(config.api_site + "/people/~/picture-urls::(original)").parsed
      data['picture'] = image['picture_urls'].select { |k, v| v['key'] == 'original'}.map { |k, v| v['__content__']}.first
      OpenStruct.new(data)
    end
    
    # TODO: find out is there pagination like in facebook
    def friends(oauth_access_token)
      token(oauth_access_token).get(config.api_site + "/people/~/connections").parsed['connections']['person']
    end
    
    def get_token(code, params = {}, options = {})
      super(code, params.merge(scope: config.scope), options)
    end
  
  protected
  
    def token(oauth_access_token)
      super(oauth_access_token, { param_name: 'oauth2_access_token', mode: :query })
    end
    
    def profile_fields
      { id: :id, first_name: :first_name, last_name: :last_name, email_address: :email, public_profile_url: :link}
    end
    
    
  end

end
