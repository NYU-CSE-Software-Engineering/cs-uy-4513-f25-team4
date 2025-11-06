Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :stocks, only: [:show, :index]

  resources :users, only: [:create, :show, :edit, :update] do
    member do
      patch :assign_associate 
    end
  end

  get "user_management", to: "users#index", as: :user_management
  get '/signup', to: 'users#new'
  post '/users',  to: 'users#create'
  resources :users, only: [:create, :show]
end


