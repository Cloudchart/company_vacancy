# TODO: error handling

class SocialNetworksController < ApplicationController
  before_filter :authorize_user
  
  def redirect_to_authirize_url
    provider = params[:provider].to_sym
    state = current_user.tokens.create(name: "#{provider}_csrf", data: { referer: request.env['HTTP_REFERER'] }).id
    redirect_to Cloudchart::OAuth.authorize_url(provider, redirect_uri: provider_callback_url(provider), state: state)
  end

  def create_access
    provider = params[:provider].to_sym
    csrf_token = current_user.tokens.find(params[:state]) rescue nil

    if csrf_token
      referer = csrf_token.data[:referer]
      csrf_token.destroy

      token = Cloudchart::OAuth.get_token(provider, params[:code], redirect_uri: provider_callback_url(provider))
      current_user.tokens.create(name: provider, data: { access_token: token.token, expires_at: token.expires_at })
      create_friends_list(token, provider)

      redirect_to referer, notice: t('messages.tokens.created')
    else
      redirect_to root_url, notice: t('messages.tokens.state_match_failed')
    end
  end

  def destroy_access
    current_user.tokens.find_by(name: params[:provider]).destroy
    redirect_to :back, notice: t('messages.tokens.destroyed')
  end

private

  def authorize_user
    authorize! :access_social_networks, User
  end

  def create_friends_list(token, provider)
    current_user.friends.where(provider: provider).destroy_all

    case provider
    when :facebook
      friends = ActiveSupport::JSON.decode(token.get('/me/friends').body)['data']

      friends.each do |friend|
        current_user.friends.create(
          provider: provider,
          external_id: friend['id'],
          name: friend['name']
        )
      end
    when :linkedin
      token.options[:mode] = :query
      token.options[:param_name] = 'oauth2_access_token'
      friends = Hash.from_xml(token.get('/v1/people/~/connections:(id,first-name,last-name)').body)

      friends['connections']['person'].each do |friend|
        current_user.friends.create(
          provider: provider,
          external_id: friend['id'],
          name: [friend['first_name'], friend['last_name']].join(' ')
        )
      end
    end
  end

end
