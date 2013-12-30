module Passport::Strategies
  class Base < Warden::Strategies::Base
    def scoped
      scoped = Passport::Model.find_model(scope).to

      unless scoped.respond_to?(:valid_for_password_authentication) || scoped.respond_to?(:authenticate_by_password)
        scoped.send(:include, Passport::Models::Password)
      end

      unless scoped.respond_to?(:serialize_into_session) || scoped.respond_to?(:serialize_from_session)
        scoped.send(:include, Passport::Models::Serialize)
      end

      scoped
    end    
  end
end