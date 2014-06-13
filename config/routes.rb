Cloudchart::Application.routes.draw do
  # Root
  #
  root 'welcome#index'
  
  # Errors
  #
  match '/404', to: 'errors#not_found', via: [:get, :post]

  # Engines
  #
  mount RailsAdmin::Engine, at: '/admin'
  mount CloudProfile::Engine, at: '/'
  mount CloudBlueprint::Engine, at: '/'

  # Concerns
  #
  concern :blockable do
    resources :blocks, only: [:create, :update, :destroy] do
      post :update_position, on: :collection
      post :update_section, on: :collection
    end
  end

  # Custom
  #
  get 'company_invite/:token_id', to: 'landings#company_invite', as: 'company_invite'

  # Resources
  #
  resources :tokens, only: :destroy

  resources :companies, shallow: true, concerns: [:blockable] do
    
    post :logo, to: 'companies#upload_logo', on: :member
    
    resources :vacancies, except: [:edit], concerns: [:blockable] do
      get :respond, on: :member
    end
    
    resources :people do
      post :send_invite_to_user, on: :member
      post :search, on: :collection
    end

    resources :events, concerns: [:blockable] do
      post :verify, on: :member
    end

    post :search, on: :collection
  end

  resources :features do
    post :vote, on: :member
  end

  resources :subscriptions, only: [:create, :update, :destroy]

end
