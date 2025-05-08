module UserRelationshipCacheable
  extend ActiveSupport::Concern

  included do
    ACTION_TYPE_INVALIDATORS = {
      "follow" => ->(current_user, target_user, controller_instance) do
        controller_instance.invalidate_relationship_cache_for(current_user)
        controller_instance.invalidate_relationship_cache_for(target_user)
      end
    }.freeze
  end

  def fetch_cached_follower_ids(user)
    Rails.cache.fetch("user/#{user.id}/follower_ids", expires_in: 5.minutes) do
      user.followers.pluck(:id)
    end
  end

  def fetch_cached_following_ids(user)
    Rails.cache.fetch("user/#{user.id}/following_ids", expires_in: 5.minutes) do
      user.followings.pluck(:id)
    end
  end

  def invalidate_relationship_cache_for(user)
    Rails.cache.delete("user/#{user.id}/follower_ids")
    Rails.cache.delete("user/#{user.id}/following_ids")
  end

  def invalidate_relationship_cache_if_needed(action_type, current_user, relationable)
    invalidator = self.class::ACTION_TYPE_INVALIDATORS[action_type]
    invalidator&.call(current_user, relationable, self)
  end
end
