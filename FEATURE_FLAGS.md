# Feature Flags in Rails Blueprint Pro

Rails Blueprint Pro includes a comprehensive feature flag system powered by Flipper, allowing you to control feature availability dynamically without code deployments.

## Quick Start

### Check if a feature is enabled

```ruby
# In controllers
if feature_enabled?(:new_dashboard)
  render :new_dashboard
else
  render :old_dashboard
end

# In views
<% with_feature(:beta_editor) do %>
  <%= render 'posts/beta_editor' %>
<% end %>

<% without_feature(:beta_editor) do %>
  <%= render 'posts/standard_editor' %>
<% end %>
```

### Require a feature (with automatic redirect)

```ruby
class BetaController < ApplicationController
  before_action -> { require_feature!(:beta_access) }
end
```

## Admin Interface

Superadmins can manage feature flags through the admin interface at `/admin/flipper`.

Features can be enabled for:
- All users
- Specific users
- Percentage of users
- User groups (admins, moderators, premium_users, beta_testers)

## Available Helper Methods

### Controller Methods

- `feature_enabled?(feature_name)` - Check if feature is enabled for current user
- `require_feature!(feature_name)` - Redirect if feature is not enabled
- `feature_enabled_for_percentage?(feature_name, percentage)` - Check with specific percentage
- `feature_enabled_for_group?(feature_name, group_name)` - Check for specific group

### View Helpers

- `feature_enabled?(feature_name, actor = current_user)` - Check feature status
- `with_feature(feature_name, &block)` - Render block only if feature is enabled
- `without_feature(feature_name, &block)` - Render block only if feature is disabled
- `feature_percentage(feature_name)` - Get current percentage value
- `feature_groups(feature_name)` - Get enabled groups for feature

## Predefined Groups

The following groups are available out of the box:
- `:admins` - Users with admin role
- `:moderators` - Users with moderator role
- `:premium_users` - Users with premium role
- `:beta_testers` - Users with beta_tester role
- `:logged_in` - Any authenticated user

## Examples

### Gradual Rollout

```ruby
# Enable for 10% of users
Flipper.enable_percentage_of_actors(:new_feature, 10)

# Increase to 50%
Flipper.enable_percentage_of_actors(:new_feature, 50)

# Enable for everyone
Flipper.enable(:new_feature)
```

### A/B Testing

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.published
    
    if feature_enabled?(:infinite_scroll)
      render :index_infinite
    else
      render :index_paginated
    end
  end
end
```

### Beta Features

```ruby
# Enable only for beta testers
Flipper.enable_group(:advanced_analytics, :beta_testers)

# In the view
<% with_feature(:advanced_analytics) do %>
  <%= link_to "Analytics", analytics_path, class: "btn btn-primary" %>
<% end %>
```

### Emergency Kill Switch

```ruby
# If a feature causes issues in production
Flipper.disable(:problematic_feature)
```

## Performance

- Feature checks are memoized per request
- In production, features can be preloaded for better performance
- Redis caching is enabled in production with 5-minute expiry

## Testing

In tests, you can easily control feature flags:

```ruby
# Enable a feature for tests
before do
  Flipper.enable(:test_feature)
end

# Clean up after tests
after do
  Flipper.disable(:test_feature)
end

# Enable for specific user
Flipper.enable_actor(:premium_feature, user)
```

## Best Practices

1. Use descriptive feature names (e.g., `:enhanced_search` not `:feature_123`)
2. Clean up old feature flags after full rollout
3. Document feature dependencies
4. Use groups for role-based features
5. Start with small percentages for gradual rollouts
6. Monitor feature performance after enabling

## Configuration

The feature flag system is configured in `config/initializers/flipper.rb`. 

Key settings:
- Memoization is enabled for performance
- Preloading is enabled in production
- Warnings for unknown features in development
- Test helper for memory adapter in tests