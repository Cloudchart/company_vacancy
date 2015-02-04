CloudApi::Engine.routes.draw do

  root to: 'welcome#index'


  get :me, controller: :users, action: :me


  get :unicorns, controller: :users, action: :unicorns


end
