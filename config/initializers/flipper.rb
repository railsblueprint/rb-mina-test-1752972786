require "flipper"
require "flipper/adapters/active_record"

Rails.application.configure do
  # Memoization ensures that only one adapter call is made per feature per request.
  config.flipper.memoize = true

  # Preload all features before each request for better performance
  config.flipper.preload = Rails.env.production?

  # Warn about unknown features in development
  config.flipper.strict = Rails.env.development? && :warn

  # Show Flipper checks in logs in development
  config.flipper.log = Rails.env.development?

  # Use memory adapter in tests
  config.flipper.test_help = Rails.env.test?
end

Flipper.configure do |config|
  # Use ActiveRecord adapter for persistence
  config.adapter { Flipper::Adapters::ActiveRecord.new }

  # Add caching layer in production for performance
  if Rails.env.production?
    config.use Flipper::Adapters::ActiveSupportCacheStore,
               Rails.cache,
               expires_in: 5.minutes
  end
end

# Register groups that can be used for enabling features
Flipper.register(:admins) do |actor|
  actor.respond_to?(:has_role?) && actor.has_role?(:admin)
end

Flipper.register(:moderators) do |actor|
  actor.respond_to?(:has_role?) && actor.has_role?(:moderator)
end

Flipper.register(:premium_users) do |actor|
  actor.respond_to?(:has_role?) && actor.has_role?(:premium)
end

Flipper.register(:beta_testers) do |actor|
  actor.respond_to?(:has_role?) && actor.has_role?(:beta_tester)
end

# Percentage-based rollout groups
Flipper.register(:logged_in) do |actor|
  actor.respond_to?(:id)
end
