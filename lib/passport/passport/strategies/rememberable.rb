module Passport::Strategies
  class Rememberable < Passport::Strategies::Base
    def valid?
      @remember_cookie = nil
      remember_cookie.present?
    end
    
    def authenticate!
      resource = model.to.serialize_from_cookie(remember_cookie)
      resource ? success!(resource) : fail
    end

    private

      def remember_cookie
        @remember_cookie ||= cookies.signed[:user_id]
      end

  end
end
