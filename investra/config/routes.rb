Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions
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
  # root "posts#index"
end

