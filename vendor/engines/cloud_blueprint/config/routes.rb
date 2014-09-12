CloudBlueprint::Engine.routes.draw do

  scope 'companies/:company_id' do
    get 'charts/new', to: 'charts#new', as: :new_company_chart
    get 'charts/:id', to: 'charts#show', as: :company_chart
  end  

  resources :charts, only: [:show, :create, :update] do
    
    get :pull,    on: :member
    get :preview, on: :member
    get :view,    on: :member
    
    resources :identities, only: [:index, :create, :update, :destroy]
    
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
