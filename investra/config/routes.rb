Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :stocks, only: [:show, :index]

  resources :users, only: [:create, :show, :edit, :update] do
    member do
      patch :assign_associate
      patch :assign_admin
      patch :update_role
    end
  end

  get "user_management", to: "users#index", as: :user_management
  get "/signup", to: "users#new"
  root "users#index"
end

