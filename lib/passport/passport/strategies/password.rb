module Passport::Strategies
  class Password < Warden::Strategies::Base
    def valid?
      scoped.valid_for_password_authentication?(params)
    end
    
    def authenticate!
      resource = scoped.authenticate_by_password(params)
      resource ? success!(resource) : fail(I18n.t('messages.invalid_email_or_password'))
    end

    private

      def scoped
        # TODO: get :user
        Passport::Model.find_model(:user).klass
      end
      
  end
end

Warden::Strategies.add(:password, Passport::Strategies::Password)
