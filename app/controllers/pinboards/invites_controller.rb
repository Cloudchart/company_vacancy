module Pinboards
  class InvitesController < ApplicationController


    def create
      pinboard  = Pinboard.find(params[:pinboard_id])

      token     = pinboard.tokens.build(name: 'access_request', target: current_user, data: {
        user_id:    current_user.id,
        user_name:  current_user.full_name,
        message:    params[:message]
      })

      token.save!

      UserMailer.request_pinboard_invite(current_user, token).deliver
      Activity.track(current_user, 'request_invite', pinboard, data: {
        message: params[:message]
      })

      respond_to do |format|
        format.json { render json: { id: token.id } }
      end

    rescue ActiveRecord::RecordInvalid

      respond_to do |format|
        format.json { render json: { errors: token.errors }, status: 402 }
      end
    end


    def update
      pinboard = Pinboard.find(params[:pinboard_id])

      authorize! :manage_pinboard_invites, pinboard

      token = pinboard.tokens.find(params[:id])
      role  = pinboard.roles.create!(user: token.target, author: current_user, value: params[:role])
      token.destroy

      UserMailer.pinboard_invite(role, role.user.email).deliver
      Activity.track(current_user, 'accept_request_access', role.owner, data: {
        user_id: @role.user.id
      })

      respond_to do |format|
        format.json { render json: { token_id: token.id, role_id: role.id } }
      end
    end


    def destroy
      pinboard = Pinboard.find(params[:pinboard_id])

      authorize! :manage_pinboard_invites, pinboard

      token = pinboard.tokens.find(params[:id])

      token.destroy
      Activity.track(current_user, 'decline_request_access', role.owner, data: {
        user_id: token.target.id
      })

      respond_to do |format|
        format.json { render json: { id: token.id } }
      end
    end

    def new
      pinboard = Pinboard.find(params[:id])

      authorize! :request_access, pinboard
    end

  end


  #   before_action :set_pinboard, only: [:create]
  #   before_action :set_token, only: [:show, :destroy, :accept, :resend]
  #
  #   authorize_resource class: :pinboard_invite, except: [:create, :resend]
  #
  #   def show
  #     @pinboard = @token.owner
  #     @author = @pinboard.user
  #
  #     pagescript_params(
  #       author_full_name: @author.full_name,
  #       author_avatar_url: @author.avatar.try(:url),
  #       token: TokenSerializer.new(@token).as_json
  #     )
  #   end
  #
  #   def create
  #     authorize! :manage_pinboard_invites, @pinboard
  #
  #     token = Token.new(owner: @pinboard, name: :invite, data: token_params)
  #
  #     if token.save
  #       respond_to do |format|
  #         format.json { render json: :ok }
  #       end
  #
  #       email = Email.find_by(address: token.data[:email]) || token.data[:email]
  #       UserMailer.pinboard_invite(email, token).deliver
  #     else
  #       respond_to do |format|
  #         format.json { render json: token.errors.messages, root: :token, status: 412 }
  #       end
  #     end
  #   end
  #
  #   def destroy
  #     @token.destroy
  #
  #     respond_to do |format|
  #       format.html { redirect_to main_app.pinboards_path }
  #       format.json { render json: @token, root: :token }
  #     end
  #   end
  #
  #   def accept
  #     pinboard = @token.owner
  #     role = current_user.roles.create!(value: @token.data[:role], owner: pinboard)
  #     @token.destroy
  #
  #     respond_to do |format|
  #       format.html { redirect_to main_app.pinboard_path(pinboard) }
  #       format.json {
  #         render json: {
  #           role: role,
  #           pinboard: pinboard
  #         }
  #       }
  #     end
  #   end
  #
  #   def resend
  #     pinboard = @token.owner
  #     authorize! :manage_pinboard_invites, pinboard
  #
  #     token = pinboard.tokens.where(name: :invite).find(params[:id])
  #     UserMailer.pinboard_invite(token.data[:email], token).deliver
  #
  #     respond_to do |format|
  #       format.json { render json: token, root: :token }
  #     end
  #   end
  #
  # private
  #
  #   def set_pinboard
  #     @pinboard = Pinboard.includes(:roles).find(params[:pinboard_id])
  #   end
  #
  #   def set_token
  #     @token = Token.find(params[:id])
  #   end
  #
  #   def token_params
  #     params.require(:token).permit(:email, :role)
  #   end
end
