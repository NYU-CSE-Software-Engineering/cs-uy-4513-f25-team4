Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # -------------------------------
  # Root
  # -------------------------------
  root "users#index"

  # -------------------------------
  # Signup / Login / Logout (from feature)
  # -------------------------------
  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # -------------------------------
  # Dashboard routes
  # -------------------------------
  get "/dashboard/trader", to: "dashboard#trader", as: :trader_dashboard
  get "/dashboard/associate", to: "dashboard#associate", as: :associate_dashboard
  get "/dashboard/manager", to: "dashboard#manager", as: :manager_dashboard
  get "/dashboard/admin", to: "dashboard#admin", as: :admin_dashboard

  # -------------------------------
  # Profile
  # -------------------------------
  get "/profile", to: "users#show", as: :profile

  # -------------------------------
  # Users (merge both PRs)
  # feature added: [:show, :edit, :update, :index]
  # main added: [:create]
  # → final: include all
  # -------------------------------
  resources :users, only: [:create, :show, :edit, :update, :index] do
    member do
      patch :assign_associate
      patch :assign_admin
      patch :update_role
    end
  end

  # User management
  get "user_management", to: "users#index", as: :user_management

  # Manage team
  get "manage_team", to: "users#manage_team", as: :manage_team

  # Associate assignment
  post "users/:id/assign_as_associate", to: "users#assign_as_associate", as: :assign_as_associate_user
  delete "users/:id/remove_associate", to: "users#remove_associate", as: :remove_associate_user

  # -------------------------------
  # Stocks (from both versions)
  # -------------------------------
  resources :stocks, only: [:show, :index]

  # -------------------------------
  # Companies (from main)
  # -------------------------------
  resources :companies, only: [:index, :new, :create, :edit, :update, :show]
end
