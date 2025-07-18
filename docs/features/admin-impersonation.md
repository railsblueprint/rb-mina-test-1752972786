# Admin Impersonation Feature

The Plus edition includes admin impersonation functionality, allowing administrators to log in as any user for support and debugging purposes.

## Overview

Admin impersonation (also known as "Login As") enables administrators to:
- Experience the application from a user's perspective
- Debug user-specific issues
- Provide better customer support
- Verify permissions and access controls

## Security Features

- Only superadmin users can impersonate
- All impersonation actions are logged
- Clear visual indicators when impersonating
- Easy return to admin account
- Session isolation prevents data leakage

## Usage

### Impersonating a User

1. Navigate to Admin Panel → Users (`/admin/users`)
2. Find the user you want to impersonate
3. Click the "Impersonate" button (person icon)
4. You'll be logged in as that user

### Visual Indicators

When impersonating, you'll see:
- A prominent banner at the top of every page
- The banner shows who you're impersonating
- A "Stop Impersonating" button to return to your admin account

### Returning to Admin Account

Click "Stop Impersonating" in the banner to:
- End the impersonation session
- Return to your admin account
- Return to the admin users page

## Implementation Details

### Controller Actions

The impersonation is handled by the Admin::UsersController:

```ruby
# app/controllers/admin/users_controller.rb
def impersonate
  user = User.find(params[:id])
  impersonate_user(user)
  redirect_to root_path
end

def stop_impersonating
  stop_impersonating_user
  redirect_to admin_users_path
end
```

### Routes

```ruby
# config/routes/admin.rb
resources :users do
  member do
    post :impersonate
  end
end
post 'stop_impersonating', to: 'users#stop_impersonating'
```

### Helper Methods

The application provides helper methods:

```ruby
# In controllers and views
current_admin_user    # The actual admin user
true_user            # Alias for current_admin_user
impersonating?       # Returns true if currently impersonating
```

### View Example

```erb
<% if impersonating? %>
  <div class="alert alert-warning impersonation-banner">
    You are impersonating <%= current_user.full_name %>
    <%= button_to "Stop Impersonating", stop_impersonating_admin_path, 
                  method: :post, 
                  class: "btn btn-sm btn-outline-dark" %>
  </div>
<% end %>
```

## Security Considerations

### Permission Checks

Only superadmin users can impersonate:

```ruby
class Admin::UsersController < Admin::BaseController
  before_action :require_superadmin!, only: [:impersonate]
  
  private
  
  def require_superadmin!
    unless current_user.superadmin?
      redirect_to admin_root_path, alert: "Unauthorized"
    end
  end
end
```

### Audit Trail

All impersonation actions should be logged:

```ruby
def impersonate
  user = User.find(params[:id])
  
  # Log the impersonation
  Rails.logger.info "Admin #{current_user.id} impersonating User #{user.id}"
  AuditLog.create!(
    user: current_user,
    action: 'impersonate',
    target: user,
    ip_address: request.remote_ip
  )
  
  impersonate_user(user)
  redirect_to root_path
end
```

### Restrictions

Certain actions are disabled during impersonation:
- Cannot impersonate another user while impersonating
- Cannot access admin panel while impersonating
- Cannot perform destructive actions on the admin account

## Best Practices

1. **Inform Users**: Consider having a privacy policy that mentions admin impersonation
2. **Limit Access**: Only grant superadmin role to trusted staff
3. **Log Everything**: Keep detailed logs of all impersonation sessions
4. **Time Limits**: Consider auto-expiring impersonation sessions
5. **Notification**: Optionally notify users when their account was accessed

## Testing

### Feature Specs

```ruby
describe "Admin impersonation" do
  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  
  before do
    sign_in admin
  end
  
  it "allows admin to impersonate user" do
    visit admin_users_path
    click_button "Impersonate"
    
    expect(page).to have_content("You are impersonating")
    expect(current_path).to eq(root_path)
  end
  
  it "allows admin to stop impersonating" do
    visit admin_users_path
    click_button "Impersonate"
    click_button "Stop Impersonating"
    
    expect(page).not_to have_content("You are impersonating")
    expect(current_path).to eq(admin_users_path)
  end
end
```

### Unit Tests

```ruby
describe Admin::UsersController do
  describe "POST #impersonate" do
    context "as superadmin" do
      it "impersonates the user" do
        post :impersonate, params: { id: user.id }
        expect(controller.current_user).to eq(user)
      end
    end
    
    context "as regular admin" do
      it "denies access" do
        post :impersonate, params: { id: user.id }
        expect(response).to redirect_to(admin_root_path)
      end
    end
  end
end
```

## Troubleshooting

### Common Issues

1. **"Unauthorized" error**: Ensure the admin user has superadmin role
2. **Session conflicts**: Clear cookies if experiencing strange behavior
3. **Missing banner**: Check that the layout includes the impersonation partial
4. **Cannot stop impersonating**: Verify the route and method are correct

### Debug Mode

Enable detailed logging for troubleshooting:

```ruby
# config/environments/development.rb
config.log_level = :debug
config.impersonation_debug = true
```