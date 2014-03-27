CloudProfile::Engine.routes.draw do
  

  # Profile landing page
  #
  get 'profile', to: 'welcome#index'


  # Login/Logout
  #
  get   'login',  to: 'authentications#new'
  post  'login',  to: 'authentications#create'
  get   'logout', to: 'authentications#destroy'
  

  # Registration
  #
  get   'register', to: 'users#new', as: :register
  post  'register', to: 'users#create'
  
  
  # Emails
  #

  scope path: 'profile' do
    resources :emails, only: [:index, :new, :create, :destroy] do
      get 'activate', on: :member
    end

    match 'emails/activation(/:token)', to: 'emails#activation', as: :email_activation, via: [:get, :post]
  end
  

  # Password
  #
  scope path: 'profile' do
    resource :password, only: [:show, :update]
  end
  

  # Social Networks / OAuth2
  #
  
  get 'oauth/callback',   to: 'social_networks#oauth_callback', as: 'oauth_callback'
  get 'oauth/logout',     to: 'social_networks#oauth_logout',   as: 'oauth_logout'
  get 'oauth/:provider',  to: 'social_networks#oauth_provider'
  

end
