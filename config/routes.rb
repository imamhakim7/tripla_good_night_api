Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    scope :auth, controller: :authentication, defaults: { format: :json } do
      post :login
      post :refresh
      post :logout
    end

    scope :do, controller: :relationship, defaults: { format: :json } do
      allowed_actions = /follow/
      post   "/:action_type/:relationable_type/:relationable_id",
             action: :create,
             constraints: { action_type: allowed_actions }
      delete "/:action_type/:relationable_type/:relationable_id",
             action: :destroy,
             constraints: { action_type: allowed_actions }
    end

    scope :my, defaults: { format: :json } do
      get "/profile", to: "user#profile"
      get "/followers", to: "user#followers"
      get "/followings", to: "user#followings"
    end

    scope :users, defaults: { format: :json } do
      get "/:id", to: "user#user_profile", constraints: { id: /\d+/ }
      get "/:id/followers", to: "user#user_followers", constraints: { id: /\d+/ }
      get "/:id/followings", to: "user#user_followings", constraints: { id: /\d+/ }
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
