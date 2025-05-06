module Api
  class ActivitySessionController < ApplicationController
    before_action :set_activity_type
    before_action :set_user, only: [ :user_sessions, :user_followers_sessions, :user_followings_sessions ]
    skip_before_action :set_activity_type, only: [ :clock_out_by_id ]

    def clock_in
      record = @current_user.activity_sessions.create!(
        activity_type: @activity_type,
        clock_in: Time.current
      )
      render json: record, status: :created
    end

    def clock_out
      record = @current_user.activity_sessions.where(
        activity_type: @activity_type,
        clock_out: nil
      ).order(created_at: :desc).first
      return render json: { error: "Not found" }, status: :not_found unless record

      record.update!(clock_out: Time.current)
      render json: record, status: :ok
    end

    def clock_out_by_id
      record = ActivitySession.find_by!(
        user: @current_user,
        id: params[:id].to_i
      )
      return render json: { error: "Not found" }, status: :not_found unless record

      record.update!(clock_out: Time.current)
      render json: record, status: :ok
    end

    def my_sessions
      records = get_activity_sessions(@current_user.id)
      render_activity_sessions(records)
    end

    def user_sessions
      records = get_activity_sessions(@user.id)
      render_activity_sessions(records)
    end

    def my_followers_sessions
      user_ids = @current_user.followers.pluck(:id)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    def user_followers_sessions
      user_ids = @user.followers.pluck(:id)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    def my_followings_sessions
      user_ids = @current_user.followings.pluck(:id)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    def user_followings_sessions
      user_ids = @user.followings.pluck(:id)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def set_activity_type
      @activity_type = params[:activity_type].to_s.downcase
      is_valid_activity_type = ActivitySession::ALLOWED_ACTIVITY_TYPES.include?(@activity_type)
      render json: { error: "Invalid activity_type" }, status: :bad_request unless is_valid_activity_type
    end

    def get_activity_sessions(user_ids)
      filter_ongoing = ActiveModel::Type::Boolean.new.cast(params[:ongoing]) if params[:ongoing].present?
      records = ActivitySession.where(
        user_id: user_ids,
        activity_type: @activity_type,
      )
      records = records.where(clock_out: nil) if filter_ongoing
      records = records.order(created_at: :desc)
      records.includes(:user)
    end

    def render_activity_sessions(activity_sessions)
      @paginated = activity_sessions.page(params[:page]).per(params[:per_page] || 10)
      render json: @paginated, status: :ok
    end
  end
end
