Rails.application.routes.draw do
  
  # Reveal health status on /up that returns 200...
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Rotas de Autenticação ---
  post '/signup', to: 'users#create'
  post '/login', to: 'authentication#login'

  get '/test_login', to: 'users#show' 

  # --- Rotas de Recursos (CRUD) ---
  resources :materials, except: [:new, :edit] do
    collection do
      get 'search'
      get :by_person_authors
      get :by_institution_authors
    end

    member do
      patch 'push_status' # Para avançar (draft -> pub -> arch)
      patch 'pull_status' # Para reverter (arch -> pub -> draft)
    end

  end

  resources :people, except: [:new, :edit]
  resources :institutions, except: [:new, :edit]

end