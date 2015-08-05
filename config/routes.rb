Cloudchart::Application.routes.draw do
  root to: 'welcome#index'

  # Engines
  #
  mount RailsAdmin::Engine, at: '/admin'
  mount CloudProfile::Engine, at: '/'
  mount CloudApi::Engine, at: '/api'

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq', constraints: Cloudchart::AdminConstraint.new

  # Concerns
  #
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

  resources :interviews, only: [:show] do
    patch :accept, on: :member
  end

  resources :pinboards, concerns: [:followable] do
    resources :roles, only: [:update, :destroy]
    resources :invites, only: [:create, :update, :destroy], controller: 'pinboards/invites'
  end

  resources :pins, except: [:index], concerns: [:followable] do
    match :approve, on: :member, via: [:put, :patch]
  end

  resources :users, only: [:show, :update], concerns: [:followable] do
    patch :subscribe, on: :member
    delete :unsubscribe, on: :member
    resources :landings, only: :create
  end

  resources :emails, only: [:create, :destroy] do
    get :verify, on: :member
    match :resend_verification, on: :member, via: [:put, :patch]
  end

  resources :invites, only: [:index, :create] do
    match :email, on: :member, via: [:put, :patch]
  end

  resources :roles, only: [:create, :update, :destroy, :show] do
    match :accept, on: :member, via: [:put, :patch]
  end

  resources :guest_subscriptions, only: :create do
    get :verify, on: :member
  end

  resources :posts_stories, only: [:update, :destroy]
  resources :activities, only: [:create]
  resources :quotes, only: [:show]
  resources :visibilities, only: :update
  resources :subscriptions, only: [:create, :update, :destroy]
  resources :tokens, only: :show
  resources :landings, only: [:show, :update, :destroy]

  # Custom
  #
  get '/collections', to: 'pinboards#index', as: :collections
  get '/collections/:id', to: 'pinboards#show', as: :collection
  get '/collections/:id/invite', to: 'pinboards/invites#new', as: :new_collection_invite

  get '/insights/:id', to: 'pins#show', as: :insight

  post '/users/:user_id/greeting', to: 'tokens#create_greeting'
  match '/user_greeting/:id', to: 'tokens#update_greeting', via: [:put, :patch]
  delete '/user_greeting/:id', to: 'tokens#destroy_greeting'
  delete '/user_welcome_tour/:id', to: 'tokens#destroy_welcome_tour'
  delete '/user_insight_tour/:id', to: 'tokens#destroy_insight_tour'

  get '/feed', to: 'users#feed', as: :feed

  delete '/logout', to: 'cloud_profile/authentications#destroy', as: :logout
  get '/old', to: 'welcome#old_browsers', as: :old_browsers
  get '/subscribe', to: 'welcome#subscribe', as: :subscribe
  get '/sandbox', to: 'sandbox#index' if Rails.env.development?

  # Preview
  #
  get '/insights/:id/preview', to: 'previews#insight', as: :insight_preview
  get '/companies/:id/preview', to: 'previews#company', as: :company_preview
  get '/collections/:id/preview', to: 'previews#pinboard', as: :pinboard_preview
  get '/users/:id/preview', to: 'previews#user', as: :user_preview

  # Twitter OAuth
  #
  get '/auth/failure', to: 'auth#failure'

  get '/auth/twitter', as: :twitter_auth
  get '/auth/twitter/callback', to: 'auth#twitter'

  get '/auth/queue', to: 'auth#edit', as: :queue
  put '/auth/queue', to: 'auth#update'

  post '/auth/developer/callback', to: 'auth#developer'

  # Should be at the end
  #
  get ':id', to: 'pages#show', as: :page

end
