CloudProfile::Engine.routes.draw do

  # Login/Logout
  #
  get   'login',  to: 'authentications#new'
  post  'login',  to: 'authentications#create'
  get   'logout', to: 'authentications#destroy'
  
  
  # Invitation
  #
  post 'invite', to: 'users#invite'
  get 'check_invite', to: 'users#check_invite'
  
  
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
    
    # Root
    #
    root to: 'main#settings'

    # Main
    #
    get 'companies', to: 'main#companies', as: :companies
    get 'newsfeed', to: 'main#activities', as: :activities
    get 'settings', to: 'main#settings', as: :settings
    get 'subscriptions', to: 'main#subscriptions', as: :subscriptions
    get 'vacancies', to: 'main#vacancies', as: :vacancies

    # Activation
    #
    match 'activation(/:token)', to: 'users#activation', as: :profile_activation, via: [:get, :post]

    # Emails
    #
    resources :emails do
      get :verify, on: :member
      match :resend_verification, on: :member, via: [:put, :patch]
    end
    
    # User
    #
    resource :user

    # Password
    #    
    post  'password/forgot', to: 'passwords#create', as: 'password_forgot'
    get   'password/:token/reset', to: 'passwords#reset', as: 'password_reset'
    post  'password/:token/reset', to: 'passwords#complete_reset'
    
    # Social Networks
    #
    get     'social_networks/attach',     to: 'social_networks#attach', as: :attach_social_network
    put     'social_networks/:id/toggle', to: 'social_networks#toggle', as: :toggle_social_network
    delete  'social_networks/:id/detach', to: 'social_networks#detach', as: :detach_social_network
    
  end
  

end
