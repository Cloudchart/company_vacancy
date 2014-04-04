require_dependency "cloud_profile/application_controller"

module CloudProfile
  class EmailsController < ApplicationController

    
    def destroy
      flash[:error] = 'Fuck off already!' unless Email.find(params[:id]).destroy
      redirect_to :emails
    end
    
    
    def activation
      @token = Token.find(params[:token])
      @email = Email.new(address: @token.data[:email])
      raise ActiveRecord::RecordNotFound if @email.invalid?
    end
    
    
    def activate
      @email = Email.find(params[:token])
      unless @email.active?
        EmailMailer.activation_email(@email).deliver
      end
      redirect_to :emails
    end
    
    
  end
end
