CloudBlueprint::Engine.routes.draw do
  
  resources :charts do
    
    get :synchronize, on: :member
    
    resources   :vacancies
    resources   :people
    resources   :nodes
    
  end
  
end
