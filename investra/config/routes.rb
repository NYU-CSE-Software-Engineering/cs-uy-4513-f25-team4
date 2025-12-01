Rails.application.routes.draw do
  # Health check endpoint (default)
  get "up" => "rails/health#show", as: :rails_health_check

  # Stocks (existing feature)
  resources :stocks, only: [:show, :index]

  # Companies
  resources :companies, only: [:index, :new, :create, :edit, :update, :show]

  # Users (shared across both features)
  resources :users, only: [:create, :show, :edit, :update, :index] do
    member do
      patch :assign_associate   # your feature
      patch :assign_admin
      patch :update_role
    end
  end

  # User management (used in request spec and redirects)
  get "user_management", to: "users#index", as: :user_management
  
  # Manage team (Portfolio Manager feature)
  get "manage_team", to: "users#manage_team", as: :manage_team
  post "users/:id/assign_as_associate", to: "users#assign_as_associate", as: :assign_as_associate_user
  delete "users/:id/remove_associate", to: "users#remove_associate", as: :remove_associate_user

  # Signup (first feature)
  get "/signup", to: "users#new"
  
  # Session routes (for login)
  get "login", to: "sessions#new", as: :new_user_session
  post "login", to: "sessions#create"

  # Root (default)
  root "users#index"
end
