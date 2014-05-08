module CloudProfile
  class ProfileMailer < ActionMailer::Base
    default from: "from@example.com"
    
    
    def activation_email(token)
      @token = token
      mail to: token.data[:address], subject: t('.activation_email', default: 'Activation e-mail')
    end
    
    
    def verification_email(token)
      @token = token
      mail to: token.data[:address], subject: t('.verification_email', default: 'Verification e-mail')
    end
    
    
    def password_reset(token)
      @token = token
      mail to: token.data[:address], subject: t('.password_reset', default: 'Password reset')
    end
    
    
  end
end
