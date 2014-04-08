require_dependency "cloud_profile/application_controller"

module CloudProfile
  class EmailsController < ApplicationController

    
    def index
      @inactive_emails = current_user.tokens.where(name: 'email-verification')
    end


    def new
      @email = Email.new
    end
    
    def create
      @email = Email.new params.require(:email).permit(:address)
      if @email.valid?
        token = current_user.tokens.create! name: 'email-verification', data: { address: @email.address }
        ProfileMailer.verification_email(token).deliver
        redirect_to :emails
      else
        render :new
      end
    end

    
    def verify
      @token = Token.where(name: 'email-verification').find(params[:id])
      @email = Email.new address: @token.data[:address]
      
      if request.post?
        if current_user.authenticate(params[:password])
          current_user.emails.create! address: @token.data[:address]
          @token.destroy
          redirect_to :emails
        else
          @password_invalid = true
        end
      end
    end
    
    
    def destroy
      @email = Email.find(params[:id]) rescue Token.find(params[:id])
      if @email.instance_of?(Email)
        @email.destroy if current_user.emails.size > 1
      else
        @email.destroy
      end
      redirect_to :emails
    end
    
    
  end
end
