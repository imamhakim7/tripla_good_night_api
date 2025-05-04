module Api
  class UserController < ApplicationController
    before_action :set_user, only: [ :show, :user_followers, :user_followings ]

    def show
      render json: @user, status: :ok
    end

    def profile
      render json: @current_user, status: :ok
    end

    def followers
      @followers = @current_user.followers
      render_users @followers
    end

    def followings
      @followings = @current_user.followings
      render_users @followings
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

    def render_users(users)
      @paginated = users.page(params[:page]).per(params[:per_page] || 10)
      render json: @paginated, status: :ok
    end
  end
end
