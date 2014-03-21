CloudProfile::Engine.routes.draw do
  

  # Profile landing page
  #
  get 'profile', to: 'welcome#index'


  # Login/Logout
  #
  get   'login', to: 'authentications#new'
  post  'login', to: 'authentications#create'
  

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
  

end
