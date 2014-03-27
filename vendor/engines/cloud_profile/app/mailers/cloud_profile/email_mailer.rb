module CloudProfile
  class EmailMailer < ActionMailer::Base
    default from: "from@example.com"
    
    
    def activation_email(email)
      @email = email
      mail to: @email.address, subject: t('.activation_email', default: 'Activation e-mail')
    end
    
  end
end
