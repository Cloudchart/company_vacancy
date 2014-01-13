module Passport::Strategies
  class Password < Passport::Strategies::Base
    def valid?
      scoped.valid_for_password_authentication?(params)
    end
    
    # TODO: check if confirmable option is passed through acts_as_passport_model helper
    def authenticate!
      resource = scoped.find_by_password(params)
      token = resource ? resource.tokens.where(name: :confirmation).first : nil

      if resource && token.blank?
        success!(resource)
      elsif resource && token.present?
        fail(I18n.t('messages.unconfirmed_account'))
      else
        fail(I18n.t('messages.invalid_email_or_password'))
      end
       
    end

  end
end
