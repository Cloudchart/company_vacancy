module CloudProfile
  class ProfileMailer < ActionMailer::Base
    default from: ENV['DEFAULT_FROM']
    
    
    def activation_email(token)
      @token = token
      mail to: token.data[:address]
    end
    
    
    def verification_email(token)
      @token = token
      mail to: token.data[:address], subject: t('.verification_email', default: 'Verification e-mail')
    end
    
    
    def password_reset(token)
      @token = token
      mail to: token.data[:address]
    end
    
    
  end
end
