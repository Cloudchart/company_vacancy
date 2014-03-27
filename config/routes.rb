Cloudchart::Application.routes.draw do

  root 'companies#index'


  # RailsAdmin engine mount point
  #
  mount RailsAdmin::Engine, at: '/admin', as: 'rails_admin'


  # CloudProfile engine mount point
  #
  mount CloudProfile::Engine, at: '/'


  #get 'sign-up', to: 'users#new', as: 'sign_up'
  #get 'login', to: 'sessions#new', as: 'login'
  #get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider', to: 'social_networks#redirect_to_authirize_url', as: 'provider'
  get 'auth/:provider/callback', to: 'social_networks#create_access', as: 'provider_callback'
  get 'auth/:provider/destroy', to: 'social_networks#destroy_access', as: 'provider_destroy'
  get 'company_invite/:token_id', to: 'landings#company_invite', as: 'company_invite'
  #get 'users/activation/:token_id', to: 'users#activate', as: 'activate_user'
  #get 'users/reactivation/:token_id', to: 'users#reactivate', as: 'reactivate_user'

  resources :users, except: [:index, :new, :destroy] do
    get :associate_with_person, on: :member
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :tokens, only: :destroy

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

    resources :events do
      post :verify, on: :member
    end
  end

  resources :features do
    post :vote, on: :member
  end

end
