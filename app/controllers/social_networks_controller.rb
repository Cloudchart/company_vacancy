# TODO: error handling

class SocialNetworksController < ApplicationController

  before_filter :authorize_user
  
  def redirect_to_authirize_url
    provider = params[:provider].to_sym
    state = current_user.tokens.create(name: "#{provider}_csrf", data: {referer: request.env['HTTP_REFERER']}).id
    redirect_to Cloudchart::OAuth.authorize_url(provider, redirect_uri: provider_callback_url(provider), state: state)
  end

  def create_access
    provider = params[:provider].to_sym
    csrf_token = current_user.tokens.where(uuid: params[:state]).first

    if csrf_token
      referer = csrf_token.data[:referer]
      csrf_token.destroy

      token = Cloudchart::OAuth.get_token(provider, params[:code], redirect_uri: provider_callback_url(provider))
      current_user.tokens.create(name: provider, data: {token: token.token, expires_at: token.expires_at})

      redirect_to referer, notice: t('messages.tokens.created')
    else
      redirect_to root_url, notice: t('messages.tokens.state_match_failed')
    end
  end

  def destroy_access
    current_user.tokens.where(name: params[:provider]).first.destroy
    redirect_to :back, notice: t('messages.tokens.destroyed')
  end

private

  def authorize_user
    authorize! :access_social_networks, User
  end

end
