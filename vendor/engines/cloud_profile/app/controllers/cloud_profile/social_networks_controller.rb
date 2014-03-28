require_dependency "cloud_profile/application_controller"

module CloudProfile
  class SocialNetworksController < ApplicationController
    
    
    def oauth_provider
      session[:social_network_redirect] = request.referer || params[:return_to]
      guard_token = Token.create(name: 'oauth-guard', data: params[:provider])
      redirect_to CloudOAuth[params[:provider]].authorize_url(redirect_uri: oauth_callback_url, state: guard_token.to_param)
    end
    

    def oauth_callback
      guard_token     = Token.find(params[:state])
      oauth_token     = CloudOAuth[guard_token.data].get_token(params[:code], redirect_uri: oauth_callback_url)
      profile         = oauth_token.get('/me').parsed
      social_network  = SocialNetwork.find_or_initialize_by(provider_id: profile['id'], name: guard_token.data)
      social_network.attributes = { data: profile, access_token: oauth_token.token, expires_at: Time.at(oauth_token.expires_at) }
      social_network.save

      session[:social_network_id] = social_network.to_param

      redirect_to_back_or_root
    ensure
      guard_token.destroy if guard_token.present?
    end
    
    
    def oauth_logout
      warden.logout(:social_network)
      redirect_to :back
    rescue
      redirect_to params[:return_to] || main_app.root_path
    end


    private
    
    def redirect_to_back_or_root
      redirect_to session.delete(:social_network_redirect) || main_app.root_path
    end
    
  end
end
