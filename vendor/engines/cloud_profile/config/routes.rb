CloudProfile::Engine.routes.draw do
  

  # Login/Logout
  #
  get   'login',  to: 'authentications#new'
  post  'login',  to: 'authentications#create'
  get   'logout', to: 'authentications#destroy'
  

  # Registration
  #
  get   'register(/:social_network_id)', to: 'users#new', as: :register
  post  'register(/:social_network_id)', to: 'users#create'
  
  
  # Social Networks / OAuth2
  #
  
  get 'oauth/callback',   to: 'social_networks#oauth_callback', as: 'oauth_callback'
  get 'oauth/logout',     to: 'social_networks#oauth_logout',   as: 'oauth_logout'
  get 'oauth/:provider',  to: 'social_networks#oauth_provider', as: 'oauth_provider'
  

  scope :profile do

    # Profile landing page
    #
    root to: 'welcome#index'
    

    # Emails
    #
    resources :emails, only: [:index, :new, :create, :destroy] do
      match 'activation(/:token)', to: 'emails#activation', as: :activation, via: [:get, :post]
      get   'activate', on: :member
    end


    # Password
    #
    resource :password, only: [:show, :update]
  end
  

end
