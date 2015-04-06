Cloudchart::Application.routes.draw do
  # Root
  #
  root to: 'welcome#index'

  # Errors
  #
  match '/404', to: 'errors#not_found', via: [:get, :post]
  match '/500', to: 'errors#internal_error', via: :all
  match '/old', to: 'errors#old_browsers', via: [:get], as: :old_browsers

  # Engines
  #
  mount RailsAdmin::Engine, at: '/admin'
  mount CloudProfile::Engine, at: '/'
  mount CloudBlueprint::Engine, at: '/'
  mount CloudApi::Engine, at: '/api'

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
  resources :companies, except: [:create, :edit], concerns: [:followable] do
    match :search, on: :collection, via: [:get, :post]
    get :verify_site_url, on: :member
    get :download_verification_file, on: :member
    get :finance, on: :member
    get :access_rights, on: :member

    resources :vacancies, except: :edit, shallow: true, concerns: [:statusable] do
      match :update_reviewers, on: :member, via: [:put, :patch]
    end

    resources :events, shallow: true do
      post :verify, on: :member
    end

    resources :invites, only: [:show, :create, :destroy], controller: 'companies/invites' do
      match :resend, on: :member, via: [:put, :patch]
      post :accept, on: :member
    end

    resources :posts, except: [:new, :edit], shallow: true
    resources :people, except: [:new, :edit], shallow: true
    resources :blocks, only: :create, type: :company
    resources :stories, only: [:show, :index, :create, :update], shallow: true
    get 'stories/:story_name', to: 'posts#index', as: :story
  end

  resources :blocks, only: [:update, :destroy] do
    resource :picture, type: :block, only: [:create, :update, :destroy]
    resource :paragraph, type: :block, only: [:create, :update, :destroy]
    resource :quote, type: :block, only: [:create, :update]
    match :reposition, on: :collection, via: [:put, :patch]
  end

  resources :posts, only: [:fetch] do
    get :fetch, on: :collection
  end

  scope 'posts/:post_id' do
    resources :blocks, only: :create, type: :post, as: :post_blocks
    resources :visibilities, only: :create, type: :post, as: :post_visibilities
    resources :posts_stories, only: :create, as: :post_posts_stories
  end

  scope 'vacancies/:vacancy_id' do
    resources :vacancy_responses, path: 'responses', only: [:index, :new, :create]
  end

  resources :vacancy_responses, only: [:show, :destroy], concerns: [:statusable] do
    post 'vote/:vote', on: :member, action: :vote, as: :vote
    post :ban_user, on: :member
  end

  resources :interviews, only: [:show] do
    patch :accept, on: :member
  end

  resources :pinboards do
    get :settings, on: :member
    resources :roles, only: [:update, :destroy]

    resources :invites, only: [:show, :create, :destroy], controller: 'pinboards/invites' do
      match :resend, on: :member, via: [:put, :patch]
      post :accept, on: :member
    end
  end

  resources :pins, except: [:index]
  resources :posts_stories, only: [:update, :destroy]

  resources :users, only: [:show, :update], concerns: [:followable] do
    get :settings, on: :member
  end

  resources :emails, only: [:create, :destroy] do
    get :verify, on: :member
    match :resend_verification, on: :member, via: [:put, :patch]
  end

  resources :quotes, only: [:show]
  resources :visibilities, only: :update
  resources :subscriptions, only: [:create, :update, :destroy]
  resources :comments, only: [:create, :update, :destroy]
  resources :roles, only: [:update, :destroy]

  # Custom
  #
  get '/insights', to: "pins#index"
  get ':id', to: 'pages#show', as: :page
  delete 'logout', to: 'cloud_profile/authentications#destroy', as: 'logout'

  # Twitter OAuth
  #
  get '/auth/twitter', as: :twitter_auth
  get '/auth/twitter/callback', to: 'auth#twitter'

  get '/auth/queue', to: 'auth#edit', as: :queue
  put '/auth/queue', to: 'auth#update'

  post '/auth/developer/callback', to: 'auth#developer'

end
