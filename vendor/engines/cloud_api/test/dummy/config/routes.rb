Rails.application.routes.draw do

  mount CloudApi::Engine => "/cloud_api"
end
