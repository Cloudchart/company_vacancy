require_dependency "cloud_profile/application_controller"

module CloudProfile
  class EmailsController < ApplicationController

    
    def index
    end
    
    
    def new
      @email = Email.new
    end
    

    def create
      @email = Email.new params.require(:email).permit(:address)
      @email.save!

      current_user.emails << @email
      
      EmailMailer.activation_email(@email).deliver
      
      redirect_to :emails
    
    rescue ActiveRecord::RecordInvalid
      render :new
    end
    
    
    def destroy
      flash[:error] = 'Fuck off already!' unless Email.find(params[:id]).destroy
      redirect_to :emails
    end
    
    
    def activation
      token = Token.find(params[:token])
      token.destroy
      redirect_to :profile
    rescue ActiveRecord::RecordNotFound
    end
    
    
    def resend_activation
      @email = Email.find(params[:id])
      unless @email.active?
        EmailMailer.activation_email(@email).deliver
      end
      redirect_to :emails
    end
    
    
  end
end
