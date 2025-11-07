Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :stocks, only: [:show, :index]
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "sessions#new"
  
  # Session routes for login/logout
  get '/login', to: 'sessions#new', as: 'new_user_session'
  post '/login', to: 'sessions#create', as: 'user_session'
  delete '/logout', to: 'sessions#destroy', as: 'destroy_user_session'
  
  get '/signup', to: 'users#new'
  
  resources :users, only: [:create, :show, :edit, :update] do
    member do
      patch :assign_admin
      patch :update_role
    end
  end
  
  get '/user_management', to: 'users#management', as: 'user_management'
end
