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
  self.throttled_responder = ->(env) { [ 429, {}, [ "Too many requests." ] ] }
end

Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0", namespace: "rack::attack")
