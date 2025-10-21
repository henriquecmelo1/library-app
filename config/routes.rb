Rails.application.routes.draw do
  get "materials/index"
  get "materials/show"
  get "materials/create"
  get "materials/update"
  get "materials/destroy"
  get "materials/search"
  

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  post '/signup', to: 'users#create'
  post '/login', to: 'authentication#login'

  get '/test_login', to: 'users#show'

  resources :materials, except: [:new, :edit] do
    collection do
      get 'search'
    end
  end


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
