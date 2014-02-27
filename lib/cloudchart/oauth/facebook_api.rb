module Cloudchart::OAuth
  module FacebookAPI

    def self.search(token_data, query, type)
      client = Cloudchart::OAuth.clients[:facebook_api]
      token = OAuth2::AccessToken.from_hash(client, token_data)
      response = token.get('/search', params: { q: query, type: type })
      ActiveSupport::JSON.decode(response.body)['data']
    end
    
  end
end
