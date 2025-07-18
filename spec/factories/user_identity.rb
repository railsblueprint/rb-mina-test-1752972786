FactoryBot.define do
  factory :user_identity do
    user
    provider { "google_oauth2" }
    uid { SecureRandom.hex(8) }
    oauth_token { "mock_token_#{SecureRandom.hex(8)}" }
    oauth_expires_at { 1.week.from_now }
    oauth_refresh_token { "mock_refresh_token_#{SecureRandom.hex(8)}" }

    trait :google do
      provider { "google_oauth2" }
    end

    trait :github do
      provider { "github" }
    end

    trait :facebook do
      provider { "facebook" }
    end

    trait :expired do
      oauth_expires_at { 1.hour.ago }
    end

    trait :no_expiration do
      oauth_expires_at { nil }
    end
  end
end
