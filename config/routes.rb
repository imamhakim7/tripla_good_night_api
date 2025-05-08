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

    activity_types = /sleep/
    scope :my, defaults: { format: :json } do
      get "/profile", to: "user#profile"
      get "/followers", to: "user#followers"
      get "/followings", to: "user#followings"
      get "/activities/:activity_type", to: "activity_session#my_sessions", constraints: { activity_type: activity_types }
      get "/followings/activities/:activity_type", to: "activity_session#my_followings_sessions", constraints: { activity_type: activity_types }
      get "/followers/activities/:activity_type", to: "activity_session#my_followers_sessions", constraints: { activity_type: activity_types }
    end

    scope :users, defaults: { format: :json } do
      get "/:id", to: "user#user_profile", constraints: { id: /\d+/ }
      get "/:id/followers", to: "user#user_followers", constraints: { id: /\d+/ }
      get "/:id/followings", to: "user#user_followings", constraints: { id: /\d+/ }
      get "/:id/activities/:activity_type", to: "activity_session#user_sessions", constraints: { activity_type: activity_types, id: /\d+/ }
      get "/:id/followers/activities/:activity_type", to: "activity_session#user_followers_sessions", constraints: { activity_type: activity_types, id: /\d+/ }
      get "/:id/followings/activities/:activity_type", to: "activity_session#user_followings_sessions", constraints: { activity_type: activity_types, id: /\d+/ }
    end

    scope :act, controller: :activity_session, defaults: { format: :json } do
      post "/:activity_type/clock_in", action: :clock_in, constraints: { activity_type: activity_types }
      patch "/:activity_type/clock_out", action: :clock_out, constraints: { activity_type: activity_types }
    end

    patch "/clock_out/:id", to: "activity_session#clock_out_by_id", defaults: { format: :json }, constraints: { id: /\d+/ }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
