module OAuth2
  class Client
    
    def facebook_auth_code
      @facebook_auth_code ||= OAuth2::Strategy::FacebookAuthCode.new(self)
    end
    
  end
end
