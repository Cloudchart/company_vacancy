CloudBlueprint::Engine.routes.draw do
  
  resources :charts do
    
    get :pull, on: :member
    
    resources   :vacancies do
      put '/', on: :collection, action: :push
    end

    resources   :people do
      put '/', on: :collection, action: :push
    end

    resources   :nodes do
      put '/', on: :collection, action: :update_batch
    end
    
  end
  
end
