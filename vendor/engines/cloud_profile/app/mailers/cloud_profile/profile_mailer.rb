module CloudProfile
  class ProfileMailer < ActionMailer::Base
    default from: ENV['FROM_EMAIL']
    
    
    def activation_email(token)
      @token = token
      mail to: token.data[:address]
    end
    
    
    def verification_email(token)
      @token = token
      @user  = token.owner
      mail(to: token.data[:address]) do |format|
        format.html { render layout: 'user_mailer_' }
      end
    end
    
    
    def password_reset(token)
      @token = token
      mail to: token.data[:address]
    end
    
    
  end
end
