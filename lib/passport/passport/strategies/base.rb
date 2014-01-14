module Passport::Strategies
  class Base < Warden::Strategies::Base
    
    protected

      def model
        Passport::Model.find_model(scope)
      end 

  end  
end
