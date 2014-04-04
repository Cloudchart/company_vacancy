module CloudProfile
  class ProfileMailer < ActionMailer::Base
    default from: "from@example.com"
    
    
    def activation_email(token)
      @token = token
      mail to: token.data['email'], subject: t('.activation_email', default: 'Activation e-mail')
    end
    
  end
end
