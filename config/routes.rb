Cloudchart::Application.routes.draw do
    root to: 'companies#index'
    resources :companies
    %i(texts images).each do |blockable|
      resources blockable, except: [:index, :show]
    end
    post 'blocks/update_position'
    post 'blocks/update_kind'
     
end
