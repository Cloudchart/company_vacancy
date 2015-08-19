require_dependency "cloud_profile/application_controller"

module CloudProfile
  class SocialNetworksController < ApplicationController
    # Attach social network to current user
    #
    def attach
      social_network = SocialNetwork.includes(:user).find(session.delete(:social_network_id))
      email          = Email.includes(:user).find_by(address: social_network.email)
      
      if social_network.user.present?
        redirect_to :settings and return
      end
      
      if email.present? && email.user != current_user
        redirect_to :settings and return
      end
      
      current_user.social_networks << social_network
      current_user.emails << Email.new(address: social_network.email)
      
      redirect_to :settings
    end
    
    
    # Detach social network from current user
    #
    def detach
      SocialNetwork.destroy(params[:id])
      redirect_to :settings
    end
    
    
    # Toggle social network visibility
    #
    def toggle
      social_network = SocialNetwork.find(params[:id])
      social_network.update!(is_visible: !social_network.is_visible?)
      redirect_to :settings
    end
    
    
    
    def oauth_provider
      session[:social_network_redirect] = params[:return_to] || request.referer
      guard_token = Token.create(name: 'oauth-guard', data: params[:provider])
      redirect_to CloudOAuth[params[:provider]].authorize_url(redirect_uri: oauth_callback_url, state: guard_token.to_param)
    end
    


    def oauth_callback
      guard_token     = Token.find(params[:state])
      oauth_token     = CloudOAuth[guard_token.data].get_token(params[:code], redirect_uri: oauth_callback_url)
      
      profile         = CloudOAuth[guard_token.data].profile(oauth_token.token)
      
      social_network  = SocialNetwork.find_or_initialize_by(provider_id: profile.id, name: guard_token.data)
      social_network.attributes = { data: profile, access_token: oauth_token.token, expires_at: Time.at(oauth_token.expires_at) }
      social_network.save

      session[:social_network_id] = social_network.to_param

    ensure
      redirect_to_back_or_root
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
