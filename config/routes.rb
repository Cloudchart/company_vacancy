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
    resources :blocks, only: [:create]
  end

  concern :statusable do
    match 'change_status/:status', on: :member, action: :change_status, as: :change_status, via: [:put, :patch]
  end

  # Custom
  #
  get 'company_invite/:token_id', to: 'landings#company_invite', as: 'company_invite'

  # Resources
  #
  resources :companies, shallow: true, concerns: [:blockable] do
    
    post :logo, to: 'companies#upload_logo', on: :member
    
    resources :vacancies, except: [:edit], concerns: [:blockable, :statusable]
    
    resources :people do
      post :send_invite_to_user, on: :member
      post :search, on: :collection
    end

    resources :events, concerns: [:blockable] do
      post :verify, on: :member
    end

    post :search, on: :collection
  end

  resources :blocks, only: [:update, :destroy] do
    post :update_position,  on: :collection
    post :update_section,   on: :collection

    resources :identities, shallow: true, controller: :block_identities, only: :destroy
  end

  resources :features do
    post :vote, on: :member
  end

  resources :tokens, only: :destroy
  resources :subscriptions, only: [:create, :update, :destroy]
  resources :comments, only: [:create, :update, :destroy]

  scope 'vacancies/:vacancy_id' do
    resources :vacancy_responses, path: 'responses', only: [:index, :new, :create] do
      post 'invite_person/:person_id', on: :collection, action: :invite_person, as: :invite_person
      delete 'kick_person/:person_id', on: :collection, action: :kick_person, as: :kick_person
    end
  end

  resources :vacancy_responses, only: [:show, :destroy], concerns: [:statusable] do
    post 'vote/:vote', on: :member, action: :vote, as: :vote
  end

end
