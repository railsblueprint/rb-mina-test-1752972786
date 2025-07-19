# OAuth Social Login Setup (Plus Tier Feature)

This guide explains how to set up OAuth social login functionality, which is exclusive to the Plus tier of Rails Blueprint.

## Overview

The Plus tier includes OAuth authentication support for:
- Google (OAuth2)
- GitHub
- Facebook
- Twitter
- LinkedIn

## Prerequisites

Before setting up OAuth, you need to:
1. Have OAuth applications created with each provider
2. Have your application's callback URLs configured with each provider

## Setting Up OAuth Providers

### 1. Google OAuth2

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - Development: `http://localhost:3000/users/auth/google_oauth2/callback`
   - Production: `https://yourdomain.com/users/auth/google_oauth2/callback`

### 2. GitHub OAuth

1. Go to GitHub Settings > Developer settings > OAuth Apps
2. Click "New OAuth App"
3. Fill in the application details
4. Set Authorization callback URL:
   - Development: `http://localhost:3000/users/auth/github/callback`
   - Production: `https://yourdomain.com/users/auth/github/callback`

### 3. Facebook OAuth

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app
3. Add Facebook Login product
4. Set Valid OAuth Redirect URIs:
   - Development: `http://localhost:3000/users/auth/facebook/callback`
   - Production: `https://yourdomain.com/users/auth/facebook/callback`

### 4. Twitter OAuth

1. Go to [Twitter Developer Portal](https://developer.twitter.com/)
2. Create a new app in your project
3. Set up OAuth 1.0a settings
4. Add callback URLs:
   - Development: `http://localhost:3000/users/auth/twitter/callback`
   - Production: `https://yourdomain.com/users/auth/twitter/callback`

### 5. LinkedIn OAuth

1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/)
2. Create a new app
3. Add Sign In with LinkedIn product
4. Set Authorized redirect URLs:
   - Development: `http://localhost:3000/users/auth/linkedin/callback`
   - Production: `https://yourdomain.com/users/auth/linkedin/callback`

## Configuration

### 1. Add OAuth Credentials

Edit your Rails credentials for each environment:

```bash
# Development/test credentials
rails credentials:edit

# Staging credentials
rails credentials:edit --environment staging

# Production credentials
rails credentials:edit --environment production
```

Add the following structure:

```yaml
oauth:
  google:
    client_id: your_google_client_id
    client_secret: your_google_client_secret
  github:
    client_id: your_github_client_id
    client_secret: your_github_client_secret
  facebook:
    app_id: your_facebook_app_id
    app_secret: your_facebook_app_secret
  twitter:
    api_key: your_twitter_api_key
    api_secret: your_twitter_api_secret
  linkedin:
    client_id: your_linkedin_client_id
    client_secret: your_linkedin_client_secret
```

### 2. Test the Configuration

1. Start your Rails server:
   ```bash
   bin/dev
   ```

2. Navigate to the login page (`/users/login`)

3. You should see social login buttons for enabled providers (by default: Google, GitHub, and Facebook)

4. Click on a provider to test the OAuth flow

## Configuration Options

### Enabling/Disabling OAuth Providers

OAuth providers can be enabled or disabled via database settings. By default:
- Google, GitHub, and Facebook are **enabled**
- Twitter and LinkedIn are **disabled**

To change these settings:

1. Access the Rails console:
   ```bash
   rails console
   ```

2. Enable a provider (e.g., Twitter):
   ```ruby
   Setting.find_by(key: "oauth.twitter.enabled").update(value: "1")
   ```

3. Disable a provider (e.g., Facebook):
   ```ruby
   Setting.find_by(key: "oauth.facebook.enabled").update(value: "0")
   ```

The changes take effect immediately - the login buttons will appear/disappear based on these settings.
## Customization

### Styling Social Login Buttons

The social login buttons are rendered in `app/views/devise/shared/_social_login.html.slim`. You can customize the appearance by modifying this file.

### Adding Additional Providers

To add more OAuth providers:

1. Add the appropriate omniauth gem to your Gemfile
2. Configure the provider in `config/initializers/devise.rb`
3. Add the provider to the User model's `omniauth_providers` array
4. Add a handler method in `app/controllers/users/omniauth_callbacks_controller.rb`
5. Update the social login partial to include the new provider button

### Handling OAuth Data

The User model includes methods to handle OAuth authentication:
- `from_omniauth(auth)` - Creates or finds a user from OAuth data
- `new_with_session(params, session)` - Pre-fills registration form with OAuth data
- `oauth_expires?` - Checks if OAuth token has expired

## Security Considerations

1. Always use HTTPS in production for OAuth callbacks
2. Keep your OAuth credentials secure and never commit them to version control
3. Regularly rotate your OAuth secrets
4. Monitor your OAuth applications for suspicious activity
5. Consider implementing rate limiting for OAuth endpoints

## Troubleshooting

### Common Issues

1. **"Invalid redirect URI" error**
   - Ensure your callback URLs match exactly in your OAuth provider settings
   - Check for trailing slashes or protocol mismatches

2. **"Credentials missing" error**
   - Verify your Rails credentials are properly set
   - Check you're using the correct environment

3. **User not created after OAuth**
   - Check your User model validations
   - Ensure the OAuth provider is returning an email address
   - Review logs for validation errors

### Debug Mode

To enable OAuth debug logging, add to your environment file:

```ruby
# config/environments/development.rb
OmniAuth.config.logger = Rails.logger
```

## Multi-Provider Support

The Plus tier OAuth implementation supports linking multiple OAuth providers to a single user account:

### How It Works

1. **Same Email Across Providers**: If a user signs in with Google (email: user@example.com) and later signs in with GitHub using the same email, both providers will be linked to the same user account.

2. **UserIdentity Model**: Each OAuth provider connection is stored as a separate UserIdentity record, allowing users to:
   - Link multiple OAuth providers to one account
   - Sign in with any linked provider
   - Maintain separate OAuth tokens per provider

3. **Account Linking Flow**:
   - New OAuth sign-in → Check if identity exists
   - If not, check if user exists with that email
   - If user exists, link the new provider
   - If no user exists, create new account

### User Benefits

- **Flexibility**: Users can sign in with their preferred provider
- **Redundancy**: If one provider is down, use another
- **No Duplicate Accounts**: Same email = same account, regardless of provider

### Helper Methods

The User model provides methods to work with linked providers:

```ruby
# Get list of linked provider names
user.linked_providers
# => ["google_oauth2", "github"]

# Check if specific provider is linked
user.linked_to?(:github)
# => true
```

### Security Considerations

- Each provider maintains its own uid (unique identifier)
- OAuth tokens are stored per provider
- Provider switching doesn't share tokens between providers
- Email verification is skipped for OAuth sign-ups (providers verify emails)

### Auto-Population of Social Profiles

When users sign in via OAuth, the system automatically populates their social profile URLs if they're blank:

- **GitHub**: Populates `github_profile` field with the user's GitHub profile URL
- **Facebook**: Populates `facebook_profile` field with the user's Facebook profile URL
- **Twitter**: Populates `twitter_profile` field (if Twitter OAuth is added)
- **LinkedIn**: Populates `linkedin_profile` field (if LinkedIn OAuth is added)

This feature:
- Only fills blank fields (won't overwrite existing data)
- Constructs URLs from available OAuth data (username, UID, etc.)
- Updates automatically on each login if the field is still blank
- Allows users to manually edit these URLs later in their profile

## Notes

- OAuth functionality is exclusive to the Plus tier
- Users can link multiple OAuth providers to the same account
- Accounts are matched by email address
- The first OAuth login creates a new user account if the email doesn't exist
- Subsequent OAuth logins with the same email link to the existing account