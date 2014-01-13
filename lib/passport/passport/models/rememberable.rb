module Passport::Models
  module Rememberable
    extend ActiveSupport::Concern
    
    module ClassMethods
      def serialize_from_cookie(id)
        find(id)
      end

    end

  end
end
