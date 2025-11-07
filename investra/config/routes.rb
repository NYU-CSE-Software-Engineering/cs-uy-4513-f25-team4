Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :stocks, only: [:show, :index]

  # --- Add this block 👇 ---
  resources :users, only: [:create, :show, :edit, :update] do
    member do
      patch :assign_associate   # ✅ This is the new route for your feature
    end
  end

  # This defines the redirect target in your test
  get "user_management", to: "users#index", as: :user_management
  # --- End new additions ---

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

