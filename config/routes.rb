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

  concern :statusable do
    match 'change_status/:status', on: :member, action: :change_status, as: :change_status, via: [:put, :patch]
  end

  concern :followable do
    post :follow, on: :member
    delete :unfollow, on: :member
  end

  # Resources
  #
  resources :companies, concerns: [:followable] do

    post :search, on: :collection
    get :verify_site_url, on: :member
    get :download_verification_file, on: :member
    get :finance, on: :member
    get :settings, on: :member
    
    put :reposition_blocks, on: :member
    
    
    resources :blocks, only: :create, type: :company
    
    
    resources :vacancies, except: :edit, shallow: true, concerns: [:statusable] do
      match :update_reviewers, on: :member, via: [:put, :patch]
    end
    
    resources :people, shallow: true do
      post :search, on: :collection
    end

    resources :events, shallow: true do
      post :verify, on: :member
    end

    resources :access_rights, controller: 'companies/access_rights'

    resources :invites, controller: 'companies/invites' do
      match :resend, on: :member, via: [:put, :patch]
      post :accept, on: :member
    end

  end

  resources :blocks, only: [:update, :destroy] do
    resources :identities, shallow: true, controller: :block_identities, only: [:index, :create, :destroy]

    resource :picture,    type: :block, only: [:create, :update, :destroy]
    resource :paragraph,  type: :block, only: [:update, :destroy]
  end

  resources :features do
    post :vote, on: :member
  end

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

  resources :subscriptions, only: [:create, :update, :destroy]
  resources :comments, only: [:create, :update, :destroy]
  resources :tags, only: [:index, :create]

  # Custom
  # 
  get ':id', to: 'pages#show', as: :page

end
