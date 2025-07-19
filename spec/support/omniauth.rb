OmniAuth.config.test_mode = true

module OmniAuthTestHelper
  # rubocop:disable Metrics/MethodLength
  def mock_auth_hash(provider, email: "user@example.com", uid: "123456", name: "Test User")
    OmniAuth.config.mock_auth[provider.to_sym] = OmniAuth::AuthHash.new({
      provider:    provider.to_s,
      uid:         uid,
      info:        {
        email:      email,
        name:       name,
        first_name: name.split.first,
        last_name:  name.split.last,
        image:      "https://example.com/avatar.jpg"
      },
      credentials: {
        token:         "mock_token_#{provider}",
        refresh_token: "mock_refresh_token_#{provider}",
        expires_at:    1.week.from_now.to_i,
        expires:       true
      },
      extra:       {
        raw_info: {
          email: email,
          name:  name,
          id:    uid
        }
      }
    })
  end
  # rubocop:enable Metrics/MethodLength

  def mock_invalid_auth_hash(provider)
    OmniAuth.config.mock_auth[provider.to_sym] = :invalid_credentials
  end

  def clear_mock_auth
    OmniAuth.config.mock_auth = {}
  end
end

RSpec.configure do |config|
  config.include OmniAuthTestHelper

  config.before do
    OmniAuth.config.test_mode = true
  end

  config.after do
    OmniAuth.config.mock_auth = {}
  end
end
