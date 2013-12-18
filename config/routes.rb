Cloudchart::Application.routes.draw do
  root to: 'companies#index'
  get 'sign-up', to: 'users#new', as: 'sign_up'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  resources :users, except: :new
  resources :sessions, only: [:new, :create, :destroy]
  resources :companies
  %i(texts images).each do |blockable|
    resources blockable, except: [:index, :show]
  end
  post 'blocks/update_position'
  post 'blocks/update_kind'
     
end
