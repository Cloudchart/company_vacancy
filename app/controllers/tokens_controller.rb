class TokensController < ApplicationController

  load_and_authorize_resource only: [
    :show,
    :update_greeting,
    :destroy_greeting,
    :destroy_welcome_tour,
    :destroy_insight_tour
  ]

  def show
    respond_to do |format|
      format.json
    end
  end

  def create_greeting
    user = User.find(params[:user_id])
    authorize! :create_greeting, user

    token = Token.find_or_create_token_by!({ data: { content: params[:content] } }.merge(name: :greeting, owner: user))

    respond_to do |format|
      format.json { render json: { id: token.id } }
    end
  end

  def update_greeting
    @token.update!(data: { content: params[:content] })

    respond_to do |format|
      format.json { render json: { id: @token.id } }
    end
  end

  def destroy_greeting
    destroy
  end

  def destroy_welcome_tour
    destroy
  end

  def destroy_insight_tour
    destroy
  end

private

  def destroy
    @token.destroy

    respond_to do |format|
      format.json { render json: { id: @token.id } }
    end
  end

end
