Cloudchart::Application.routes.draw do
  root 'companies#index'

  get 'sign-up', to: 'users#new', as: 'sign_up'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider', to: 'social_networks#redirect_to_authirize_url', as: 'provider'
  get 'auth/:provider/callback', to: 'social_networks#create_access', as: 'provider_callback'
  get 'auth/:provider/destroy', to: 'social_networks#destroy_access', as: 'provider_destroy'

  resources :users, except: [:index, :new, :destroy] do
    get :activate, on: :member
    get :reactivate, on: :member
    get :associate_with_person, on: :member
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :companies, shallow: true do
    resources :vacancies
    resources :blocks
    resources :people do
      post :send_invite_to_user, on: :member
    end
  end

  post 'blocks/update_position'
  post 'blocks/update_section'

end
