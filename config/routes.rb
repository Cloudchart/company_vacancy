Cloudchart::Application.routes.draw do
  root 'companies#index'

  get 'sign-up', to: 'users#new', as: 'sign_up'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider', to: 'social_networks#redirect_to_authirize_url', as: 'provider'
  get 'auth/:provider/callback', to: 'social_networks#create_access', as: 'provider_callback'
  get 'auth/:provider/destroy', to: 'social_networks#destroy_access', as: 'provider_destroy'

  resources :users, except: [:index, :new] do
    get :activate, on: :member
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :companies
  resources :password_resets, only: [:new, :create, :edit, :update]

  %i(texts images).each do |blockable|
    resources blockable, except: [:index, :show]
  end
  
  post 'blocks/update_position'
  post 'blocks/update_kind'

end
  