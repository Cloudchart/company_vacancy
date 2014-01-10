module Passport::Strategies
  class Password < Warden::Strategies::Base
    def valid?
      scoped.valid_for_password_authentication?(params)
    end
    
    def authenticate!
      resource = scoped.find_by_password(params)
      resource ? success!(resource) : fail(I18n.t('messages.invalid_email_or_password'))
    end

    private

      def scoped
        Passport::Model.find_model(scope).to
      end
      
  end
end
