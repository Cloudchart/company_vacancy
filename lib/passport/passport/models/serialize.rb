module Passport::Models
  module Serialize
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      def serialize_into_session(user)
        user.id
      end

      def serialize_from_session(id)
        find(id)
      end      

    end

  end  
end
