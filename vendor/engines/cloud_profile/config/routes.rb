CloudProfile::Engine.routes.draw do
  

  # Login/Logout
  #
  get   'login',  to: 'authentications#new'
  post  'login',  to: 'authentications#create'
  get   'logout', to: 'authentications#destroy'
  

  # Registration
  #
  get   'register',           to: 'users#new',              as: :register
  post  'register',           to: 'users#create'
  get   'register/complete',  to: 'users#create_complete',  as: :register_complete
  
  
  # Social Networks / OAuth2
  #
  
  get 'oauth/callback',   to: 'social_networks#oauth_callback', as: 'oauth_callback'
  get 'oauth/logout',     to: 'social_networks#oauth_logout',   as: 'oauth_logout'
  get 'oauth/:provider',  to: 'social_networks#oauth_provider', as: 'oauth_provider'
  

  scope :profile do

    # Activation
    #
    match 'activation(/:token)', to: 'users#activation', as: :profile_activation, via: [:get, :post]


    # Profile landing page
    #
    root to: 'welcome#index'   
    get 'settings', to: 'welcome#settings', as: :settings
    
    
    # Emails
    #
    resources :emails


    # Password
    #
    resource :password, only: [:show, :update]
  end
  

end
