CloudBlueprint::Engine.routes.draw do
  
  resources :charts do
    
    resources   :vacancies
    resources   :people
    
  end
  
end
