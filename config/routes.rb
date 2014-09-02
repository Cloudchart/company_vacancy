Cloudchart::Application.routes.draw do
  # Root
  #
  root to: 'welcome#index'
  
  # Errors
  #
  match '/404', to: 'errors#not_found', via: [:get, :post]
  match '/500', to: 'errors#internal_error', via: :all

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

  # Resources
  #
  resources :companies, shallow: true, concerns: [:blockable] do

    post :logo, to: 'companies#upload_logo', on: :member
    post :search, on: :collection
    get :verify_site_url, on: :member
    get :download_verification_file, on: :member
    # post :transfer_ownership, on: :member
    # get :obtain_ownership, on: :member
    
    resources :vacancies, except: [:edit], concerns: [:blockable, :statusable] do
      match :update_reviewers, on: :member, via: [:put, :patch]
    end
    
    resources :people do
      post :search, on: :collection
      match :make_owner, on: :member, via: [:put, :patch]
      post :invite_user, on: :member
    end

    resources :events, concerns: [:blockable] do
      post :verify, on: :member
    end

  end

  resources :blocks, only: [:update, :destroy] do
    post :update_position,  on: :collection
    post :update_section,   on: :collection

    resources :identities, shallow: true, controller: :block_identities, only: [:index, :create, :destroy]
  end

  resources :features do
    post :vote, on: :member
  end

  resources :subscriptions, only: [:create, :update, :destroy]
  resources :comments, only: [:create, :update, :destroy]
  resources :favorites, only: [:create, :destroy]

  scope 'vacancies/:vacancy_id' do
    resources :vacancy_responses, path: 'responses', only: [:index, :new, :create]
  end

  resources :vacancy_responses, only: [:show, :destroy], concerns: [:statusable] do
    post 'vote/:vote', on: :member, action: :vote, as: :vote
    post :ban_user, on: :member
  end

  resources :company_invites, only: [:show, :create, :destroy] do
    patch :accept, on: :member
  end

  # Custom
  # 
  # get 'company_invite/:token', to: 'landings#company_invite', as: :company_invite
  # match 'accept_company_invite/:token', to: 'invitations#accept_company_invite', as: :accept_company_invite, via: [:put, :patch]
  # delete 'company_invites/:id/cancel', to: 'invitations#cancel_company_invite', as: :cancel_company_invite
  get ':id', to: 'pages#show', as: :page

end
