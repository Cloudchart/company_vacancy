CloudBlueprint::Engine.routes.draw do
  
  resources :charts do
    
    resources :vacancies, only: [:index, :new, :create, :edit, :update, :destroy]
    
  end
  
end
