CloudBlueprint::Engine.routes.draw do
  
  resources :charts do
    
    get :pull, on: :member
    
    resources   :vacancies
    resources   :people
    resources   :nodes do
      
      put '/', on: :collection, action: :update_batch
      
    end
    
  end
  
end
