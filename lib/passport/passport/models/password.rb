module Passport::Models
  module Password
    extend ActiveSupport::Concern
    
    module ClassMethods
      def valid_for_password_authentication?(params)
        params['email'] && params['password']
      end

      def find_by_password(params)
        find_by(email: params['email']).try(:authenticate, params['password'])
      end    

    end

  end  
end
