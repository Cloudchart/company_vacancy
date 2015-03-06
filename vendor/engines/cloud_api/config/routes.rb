CloudApi::Engine.routes.draw do


  root to: 'welcome#index'


  get :me, controller: :users, action: :me


  get :unicorns, controller: :users, action: :unicorns


  get '/pins/:id', controller: :pins, action: :show


  get '/pinboards/:id', controller: :pinboards, action: :show


  get '/posts/:id', controller: :posts, action: :show


end
