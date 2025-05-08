module Api
  class ActivitySessionController < ApplicationController
    include UserRelationshipCacheable

    before_action :set_activity_type
    before_action :set_user, only: [ :user_sessions, :user_followers_sessions, :user_followings_sessions ]
    skip_before_action :set_activity_type, only: [ :clock_out_by_id ]

    def clock_in
      record = @current_user.activity_sessions.create!(
        activity_type: @activity_type,
        clock_in: Time.current
      )
      invalidate_activity_session_cache_for(@current_user.id)
      render json: record, status: :created
    end

    def clock_out
      record = @current_user.activity_sessions.where(
        activity_type: @activity_type,
        clock_out: nil
      ).order(created_at: :desc).first
      return render json: { error: "Not found" }, status: :not_found unless record

      do_clock_out_for(record)
    end

    def clock_out_by_id
      record = ActivitySession.find_by!(
        user: @current_user,
        id: params[:id].to_i
      )
      return render json: { error: "Not found" }, status: :not_found unless record

      do_clock_out_for(record)
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
      user_ids = fetch_cached_follower_ids(@current_user)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    def user_followers_sessions
      user_ids = fetch_cached_follower_ids(@user)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    def my_followings_sessions
      user_ids = fetch_cached_following_ids(@current_user)
      records = get_activity_sessions(user_ids)
      render_activity_sessions(records)
    end

    def user_followings_sessions
      user_ids = fetch_cached_following_ids(@user)
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
      user_ids = Array(user_ids).uniq.sort
      filters = {}.tap do |h|
        h[:ongoing] = ActiveModel::Type::Boolean.new.cast(params[:ongoing]) if params[:ongoing].present?
        h[:finished] = ActiveModel::Type::Boolean.new.cast(params[:finished]) if params[:finished].present?
        h[:from_last_week] = ActiveModel::Type::Boolean.new.cast(params[:from_last_week]) if params[:from_last_week].present?
      end.compact

      cache_key = cache_key_for_sessions(user_ids, filters)

      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        records = ActivitySession.where(user_id: user_ids, activity_type: @activity_type)
        records = records.ongoing if filters[:ongoing]
        records = records.finished if filters[:finished]
        records = records.from_last_week if filters[:from_last_week]
        records = records.order(created_at: :desc)
        records.includes(:user).to_a
      end
    end

    def cache_key_for_sessions(user_ids, filters = {})
      base = "activity_sessions/#{@activity_type}/#{user_ids.join('-')}"
      flags = filters.map { |k, v| "#{k}=#{v}" }.join("&")
      page = params[:page] || 1
      per = params[:per_page] || 10
      updated = ActivitySession.where(user_id: user_ids, activity_type: @activity_type).maximum(:updated_at).to_i
      "#{base}?#{flags}&page=#{page}&per=#{per}&updated=#{updated}"
    end

    def do_clock_out_for(record)
      begin
        ActivitySession.transaction do
          record.update!(clock_out: Time.current)
          invalidate_activity_session_cache_for(@current_user.id)
        end
        render json: record, status: :ok
      rescue ActiveRecord::StaleObjectError
        render json: { error: "This session was updated by another user" }, status: :conflict
      end
    end

    def invalidate_activity_session_cache_for(user_id)
      Rails.cache.delete_matched("activity_sessions/#{@activity_type}/#{user_id}*")
    end

    def render_activity_sessions(activity_sessions)
      @paginated = Kaminari.paginate_array(activity_sessions).page(params[:page] || 1).per(params[:per_page] || 10)
      render json: @paginated, status: :ok
    end
  end
end
