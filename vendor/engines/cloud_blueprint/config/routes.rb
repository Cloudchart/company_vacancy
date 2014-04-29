CloudBlueprint::Engine.routes.draw do
  
  resources :charts do
    
    resources :vacancies, only: [:create]
    
  end
  
end
