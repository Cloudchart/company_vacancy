require_dependency "cloud_profile/application_controller"

module CloudProfile
  class EmailsController < ApplicationController


    before_action :require_authenticated_user!


    def create
      email = Email.new(params.permit(:address))
      
      if email.valid?
        
        token = current_user.tokens.create name: 'email_verification', data: { address: email.address }
        ProfileMailer.verification_email(token).deliver
        
        respond_to do |format|
          format.json { render json: current_user, serializer: PersonalSerializer, only: :verification_tokens, root: false }
        end
        
      else
        
        respond_to do |format|
          format.json { render json: :nok, status: 412 }
        end
        
      end
    end

    
    def verify
      @token = Token.where(name: 'email_verification').find(params[:id])
      current_user.emails.create!(address: @token.data[:address])

      Token.transaction do
        Token.where(name: 'email_verification').each do |token|
          token.destroy if token.data[:address] == @token.data[:address] 
        end
      end

      redirect_to cloud_profile.settings_path
    end
    
    
    def resend_verification
      token = current_user.tokens.where(name: 'email_verification').find(params[:id])
      ProfileMailer.verification_email(token).deliver
      
      respond_to do |format|
        format.json { render json: :ok, status: 200 }
      end
    end
    
    
    def destroy
      email = Email.find(params[:id]) rescue Token.find(params[:id]) rescue nil

      email.destroy if email && email.instance_of?(Token) or current_user.emails.size > 1
      
      respond_to do |format|
        format.json { render json: current_user, serializer: PersonalSerializer, only: [:emails, :verification_tokens], root: false }
      end
      
    end
    

  end
end
