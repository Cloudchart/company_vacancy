class EmailsController < ApplicationController

  authorize_resource

  def create
    email = Email.new(params.permit(:address))

    if email.valid?

      token = current_user.tokens.create name: 'email_verification', data: { address: email.address }
      CloudProfile::ProfileMailer.verification_email(token).deliver

      respond_to do |format|
        format.json { render json: current_user, serializer: CloudProfile::PersonalSerializer, only: :verification_tokens, root: false }
      end

    else

      respond_to do |format|
        format.json { render json: { message: 'This email is invalid or already in use' }, status: 412 }
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

    redirect_to user_path(current_user, anchor: "settings")

  rescue ActiveRecord::RecordNotFound

    respond_to do |format|
      format.html
    end
  end


  def resend_verification
    token = current_user.tokens.where(name: 'email_verification').find(params[:id])
    CloudProfile::ProfileMailer.verification_email(token).deliver
    
    respond_to do |format|
      format.json { render json: :ok, status: 200 }
    end
  end


  def destroy
    @email = Email.find(params[:id]) rescue Token.find(params[:id]) rescue nil
    @email.try(:destroy)

    respond_to do |format|
      format.json { render json: current_user, serializer: CloudProfile::PersonalSerializer, only: [:emails, :verification_tokens], root: false }
    end
  end

end
