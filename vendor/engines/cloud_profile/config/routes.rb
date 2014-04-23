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

    
    # Activities
    # 
    get 'newsfeed', to: 'activities#index', as: :newsfeed
    

    # Companies
    # 
    resources :companies, only: :index

    
    # Emails
    #
    resources :emails do
      match 'verify', on: :member, via: [:get, :post]
      get 'resend_verification', on: :member
    end
    

    # User
    #
    resource :user


    # Password
    #
    resource :password, only: [:show, :update] do
      get   'forgot', to: 'passwords#new',    on: :member
      post  'forgot', to: 'passwords#create', on: :member
    end
    
    get   'password/:token/reset', to: 'passwords#reset', as: 'password_reset'
    post  'password/:token/reset', to: 'passwords#reset_complete'
    
    
    # Social Networks
    #
    
    get     'social_networks/attach',     to: 'social_networks#attach', as: :attach_social_network
    put     'social_networks/:id/toggle', to: 'social_networks#toggle', as: :toggle_social_network
    delete  'social_networks/:id/detach', to: 'social_networks#detach', as: :detach_social_network
    
  end
  

end
