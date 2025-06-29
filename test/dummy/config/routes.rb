Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Test routes for Frontyard controller tests
  resources :test, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  # Edge case routes (RESTful + custom collection actions)
  resources :edge_case, only: [:index, :show] do
    collection do
      get :complex_action
      get :action_with_optional_params
      get :form_params
    end
  end

  # Form test routes
  get "users/form_test"
  get "admin_users/form_test"

  # Test events route for application form tests
  post "test_events", to: "test_events#create"

  # Defines the root path route ("/")
  root to: "application#index"
end
