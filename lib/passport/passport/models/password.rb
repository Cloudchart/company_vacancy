module Passport::Models
  module Password
    extend ActiveSupport::Concern
    
    included do
      require 'passport/strategies/password'
    end

    module ClassMethods
      def valid_for_password_authentication?(params)
        params[Passport::Model.find_by_attr(self).to_s] && params['password']
      end

      def authenticate_by_password(params)
        find_by_attr = Passport::Model.find_by_attr(self)
        resource = find_by(find_by_attr => params[find_by_attr.to_s])

        if resource
          resource.authenticate(params['password'])
        else
          false
        end
      end

    end

  end  
end
