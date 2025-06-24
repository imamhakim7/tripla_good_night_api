source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Redis for caching
gem "redis", "~> 5.4"

# Use for Rack middleware to throttle requests and block abusive clients
gem "rack-attack", "~> 6.7" # https://github.com/rack/rack-attack

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"
gem "kaminari" # https://github.com/kaminari/kaminari
gem "active_model_serializers", "~> 0.10.2"

gem "bcrypt", "3.1.20" # https://github.com/bcrypt-ruby/bcrypt-ruby
gem "jwt", "~> 2.10.1" # https://github.com/jwt/ruby-jwt
gem "strong_migrations", "~> 2.4.0" # https://github.com/ankane/strong_migrations
gem "simple_command", "~> 1.0.1" # https://github.com/nebulab/simple_command

gem "pry", "~> 0.15.0" # https://github.com/pry/pry

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing framework
  gem "rspec-rails", "~> 8.0.0" # https://github.com/rspec/rspec-rails
  gem "shoulda-matchers", "~> 6.0" # https://github.com/thoughtbot/shoulda-matchers
  gem "factory_bot_rails" # https://github.com/thoughtbot/factory_bot_rails
  gem "faker" # https://github.com/faker-ruby/faker

  # https://github.com/DatabaseCleaner/database_cleaner
  gem "database_cleaner-active_record", "~> 2.2.1"

  gem "dotenv", "3.1.8" # https://github.com/bkeepers/dotenv
end
