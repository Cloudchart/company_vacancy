CloudBlueprint::Engine.routes.draw do

  resources :companies, except: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :charts, only: :new
  end
  
  resources :charts, except: [:index, :new, :create, :edit] do
    
    get :pull,    on: :member
    get :preview, on: :member
    
    resources :identities, only: [:create, :update, :destroy]
    
    resources :vacancies do
      put '/', on: :collection, action: :push
    end

    resources :people do
      put '/', on: :collection, action: :push
    end

    resources :nodes do
      put '/', on: :collection, action: :update_batch
    end
    
  end
  
end
