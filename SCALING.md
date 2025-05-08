# 📈 Scalable Architecture Strategy

To support a growing user base, high data volume, and concurrent requests, we apply the following strategies in the Rails API project.

---

## ⚙️ 1. Database Optimization

Efficient queries reduce response time and memory usage.

### ✅ Indexing

```ruby
# Indexes for activity_sessions table
add_index :activity_sessions, [ :user_id, :activity_type ], name: 'index_activity_sessions_on_user_and_type'
add_index :activity_sessions, [ :user_id, :clock_in, :clock_out ], name: 'index_activity_sessions_on_user_and_times'

# Indexes for relationships table
add_index :relationships, [ :user_id, :action_type ], name: 'index_relationships_on_user_and_action_type'
add_index :relationships, [ :user_id, :relationable_type, :relationable_id ], name: 'index_relationships_on_user_and_relationable'

# Index for users table
add_index :users, :refresh_token, name: 'index_users_on_refresh_token'
```

### ✅ Query Optimization

Only retrieve needed fields and eager load associations.

```ruby
records = ActivitySession.where(user_id: user_ids, activity_type: @activity_type)
records = records.ongoing if filters[:ongoing]
records = records.finished if filters[:finished]
records = records.from_last_week if filters[:from_last_week]
records = records.order(created_at: :desc) # This one
records.includes(:user).to_a
```

---

## 🧠 2. Caching

Cache frequent and expensive queries to reduce DB load, example: UserRelationshipCacheable.

Invalidation Cache also

### ✅ Redis Fragment Cache

```ruby
module UserRelationshipCacheable
  extend ActiveSupport::Concern

  included do
    ACTION_TYPE_INVALIDATORS = {
      "follow" => ->(current_user, target_user) do
        invalidate_relationship_cache_for(current_user)
        invalidate_relationship_cache_for(target_user)
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
    invalidator&.call(current_user, relationable)
  end
end

```

### ✅ Memoization

Avoid repeated DB hits in a single request.

```ruby
@user ||= User.find(decoded_auth_token["id"]) if decoded_auth_token
```

---

## 🔄 3. Scalable API Design

Design endpoints for large datasets and flexible filtering.

### ✅ Pagination

```ruby
@paginated = records.page(params[:page] || 1).per(params[:per_page] || 10)
```

### ✅ Boolean Filtering

```ruby
if ActiveModel::Type::Boolean.new.cast(params[:ongoing])
  records = records.where(clock_out: nil)
end
```

---

## 🛡️ 4. Concurrency Handling

Ensure safe and consistent writes under high load.

### ✅ Atomic Transactions

```ruby
ActivitySession.transaction do
  record.update!(clock_out: Time.current)
end

# or

@current_user.transaction { @current_user.update!(refresh_token: nil) }
```

---

## ☁️ 5. Infrastructure Scalability

Scale horizontally using Docker and manage concurrency.

### ✅ Puma & Connection Pool

```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY", 4) # Adjusted by CPU Core
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
```

### ✅ Docker Deployment

```dockerfile
# For production
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

---

## 🔐 6. Security & Rate Limiting

Prevent abuse and secure user sessions.

### ✅ JWT Token Expiry

```ruby
def self.encoded_auth_token(payload, expires_in: 24.hours.from_now)
  payload[:exp] = expires_in.to_i
  payload[:iat] = Time.current.to_i
  JWT.encode(payload, Rails.application.credentials.secret_key_base)
end
```

### ✅ Rack Attack Rate Limit & Block IP set on ENV

```ruby
class Rack::Attack
  # Throttle requests per IP address (100 requests per minute)
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # Block all requests from certain IPs (e.g., blacklisted IP)
  blacklist_ips = ENV["BLACKLISTED_IPS"].to_s.split(",").map(&:strip)
  blocklist("block IPs") do |req|
    blacklist_ips.include?(req.ip)
  end

  # Custom response to rate-limited requests
  self.throttled_response = ->(env) { [ 429, {}, [ "Too many requests." ] ] }
end

Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0", namespace: "rack::attack")
```

## 🚀 7. TODO: Background Jobs

Move long-running tasks out of request cycle.

### ✅ Job [Not Implemented Yet] TODO: Create Job to Analytics Table or DB Analize Users ActivitySession Behaviour

```ruby
class ActivityLogJob < ApplicationJob
  queue_as :default

  def perform(activity_session_id)
    AnalyticsService.log_session(activity_session_id)
  end
end

ActivityLogJob.perform_later(record.id)
```

---
