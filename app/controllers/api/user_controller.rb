module Api
  class UserController < ApplicationController
    include UserRelationshipCacheable

    before_action :set_user, only: [ :user_profile, :user_followers, :user_followings ]

    def profile
      render json: @current_user, status: :ok
    end

    def followers
      user_ids = fetch_cached_follower_ids(@current_user)
      render_users(get_users_by_ids(user_ids))
    end

    def followings
      user_ids = fetch_cached_following_ids(@current_user)
      render_users(get_users_by_ids(user_ids))
    end

    def user_profile
      render json: @user, status: :ok
    end

    def user_followers
      @followers = @user.followers
      render_users @followers
    end

    def user_followings
      @followings = @user.followings
      render_users @followings
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def get_users_by_ids(user_ids)
      User.where(id: user_ids).order(id: :desc)
    end

    def render_users(users)
      @paginated = users.page(params[:page] || 1).per(params[:per_page] || 10)
      render json: @paginated, status: :ok
    end
  end
end
