module OAuth2
  module Strategy
    class FacebookAuthCode < OAuth2::Strategy::AuthCode

      def get_token(code, params = {}, options = {})
        super(code, params.merge(parse: :query), options)
      end
      
    end
  end
end
