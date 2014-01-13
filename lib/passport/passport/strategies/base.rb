module Passport::Strategies
  class Base < Warden::Strategies::Base
    
    protected

      def scoped
        Passport::Model.find_model(scope).to
      end 

  end  
end
