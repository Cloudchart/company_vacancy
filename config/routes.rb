Cloudchart::Application.routes.draw do
  root 'companies#index'

  get 'sign-up', to: 'users#new', as: 'sign_up'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider', to: 'social_networks#redirect_to_authirize_url', as: 'provider'
  get 'auth/:provider/callback', to: 'social_networks#create_access', as: 'provider_callback'
  get 'auth/:provider/destroy', to: 'social_networks#destroy_access', as: 'provider_destroy'
  get 'company_invite/:token_id', to: 'landings#company_invite', as: 'company_invite'

  resources :users, except: [:index, :new, :destroy] do
    get :activate, on: :member
    get :reactivate, on: :member
    get :associate_with_person, on: :member
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :companies, shallow: true do
    resources :vacancies

    resources :blocks do
      post :update_position, on: :collection
      post :update_section, on: :collection
    end
    
    resources :people do
      post :send_invite_to_user, on: :member
      post :search, on: :collection
    end
  end

  resources :tokens, only: :destroy

end
