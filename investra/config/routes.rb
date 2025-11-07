Rails.application.routes.draw do
  # Health check endpoint (default)
  get "up" => "rails/health#show", as: :rails_health_check

  # Stocks (existing feature)
  resources :stocks, only: [:show, :index]

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

  # Signup (first feature)
  get "/signup", to: "users#new"

  # Root (default)
  root "users#index"
end

