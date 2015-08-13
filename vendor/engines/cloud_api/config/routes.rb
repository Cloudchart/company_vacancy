CloudApi::Engine.routes.draw do


  root to: 'welcome#index'


  get :node, controller: :nodes, action: :fetch


  get :me, controller: :users, action: :me

  get '/users/:id', controller: :users, action: :show

  get :unicorns, controller: :users, action: :unicorns

  post :unicorns, controller: :users, action: :create_unicorn


  get '/pins/:id', controller: :pins, action: :show


  get '/pinboards/:id', controller: :pinboards, action: :show


  get '/companies/:id', controller: :companies, action: :show


  get '/posts/:id', controller: :posts, action: :show


  get '/search', controller: :search, action: :index

  # Notifications
  #
  post '/report_content', to: 'notifications#report_content', format: 'json'
  post '/track', to: 'notifications#post_to_slack', format: 'json'

end
