Rails.application.routes.draw do
  # Health check endpoint 
  get "up" => "rails/health#show", as: :rails_health_check

  # Stocks 
  resources :stocks, only: [:show, :index]

  # Users
  resources :users, only: [:create, :show, :edit, :update, :index] do
    member do
      patch :assign_associate 
      patch :assign_admin
      patch :update_role
    end
  end

  # User management 
  get "user_management", to: "users#index", as: :user_management

  # Dashboard routes
  get 'dashboards/trader', to: 'dashboards#trader', as: 'trader_dashboard'
  get 'dashboards/associate', to: 'dashboards#associate', as: 'associate_dashboard'
  get 'dashboards/manager', to: 'dashboards#manager', as: 'manager_dashboard'
  get 'dashboards/admin', to: 'dashboards#admin', as: 'admin_dashboard'
  
  # Manage team 
  get "manage_team", to: "users#manage_team", as: :manage_team
  post "users/:id/assign_as_associate", to: "users#assign_as_associate", as: :assign_as_associate_user
  delete "users/:id/remove_associate", to: "users#remove_associate", as: :remove_associate_user

  # Signup 
  get "/signup", to: "users#new"

  get 'profile', to: 'users#profile', as: 'profile'
  
  # Session routes 
  get "login", to: "sessions#new", as: :new_user_session
  post "login", to: "sessions#create"
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  # Root 
  root "users#index"
end



