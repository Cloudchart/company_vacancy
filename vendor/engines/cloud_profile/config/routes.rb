CloudProfile::Engine.routes.draw do
  

  # Profile landing page
  #
  get 'profile', to: 'welcome#index'


  # Login/Logout
  #
  get   'login', to: 'authentications#new', as: 'login'
  post  'login', to: 'authentications#create'
  

  # Registration
  #
  get   'register', to: 'users#new', as: 'register'
  post  'register', to: 'users#create'
  

  # Emails
  #
  resources :emails, only: [:index, :new, :create, :destroy]


  # Email activation
  #
  get   'emails/activation/(:token)',   to: 'emails#activation', as: 'email_activation'
  post  'emails/activation',            to: 'emails#activate'
  get   'emails/:id/activate',          to: 'emails#resend_activation', as: 'activate_email'
  

end
