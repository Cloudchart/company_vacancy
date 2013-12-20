module Passport::Models
  module Password
    extend ActiveSupport::Concern
    
    included do
      require 'passport/strategies/password'

      class << self
        def valid_for_password_authentication?(params)
          # TODO: extract email from Passport::Model
          # params[find_attrs.to_s] && params['password']
          params['email'] && params['password']
        end

        def authenticate_by_password(params)
          # TODO: extract email from Passport::Model
          # resource = find_by(find_attrs => params[find_attrs.to_s])
          resource = find_by(email: params['email'])

          if resource
            resource.authenticate(params['password'])
          else
            false
          end
        end
      end

    end

    # private

    # def passport_model
    #   Passport::Model.find_model(self.name.underscore.to_sym)
    # end

    # def find_attrs
    #   passport_model.strategy_options[:find_by]
    # end

  end  
end
