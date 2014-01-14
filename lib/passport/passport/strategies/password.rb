module Passport::Strategies
  class Password < Passport::Strategies::Base
    def valid?
      model.to.valid_for_password_authentication?(params)
    end
    
    def authenticate!
      resource = model.to.find_by_password(params)
      resource ? success!(resource) : fail(I18n.t('messages.invalid_email_or_password'))
    end

  end
end
