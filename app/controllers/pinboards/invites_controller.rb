module Pinboards
  class InvitesController < ApplicationController

    before_action :set_pinboard, only: [:create]
    before_action :set_token, only: [:show, :destroy, :accept, :resend]

    authorize_resource class: :pinboard_invite, except: [:create, :resend]

    def show
      
    end

    def create
      authorize! :manage_pinboard_invites, @pinboard

      token = Token.new(owner: @pinboard, name: :invite, data: token_params)

      if token.save
        respond_to do |format|
          format.json { render json: :ok }
        end

        email = CloudProfile::Email.find_by(address: token.data[:email]) || token.data[:email]
        UserMailer.pinboard_invite(email, token).deliver
      else
        respond_to do |format|
          format.json { render json: token.errors.messages, root: :token, status: 412 }
        end
      end
    end

    def destroy
      
    end

    def accept
      
    end

    def resend
      authorize! :manage_pinboard_invites, @token.owner
    end

  private

    def set_pinboard
      @pinboard = Pinboard.includes(:roles).find(params[:pinboard_id])
    end

    def set_token
      @token = Token.find(params[:id])
    end

    def token_params
      params.require(:token).permit(:email, :role)
    end

  end
end
