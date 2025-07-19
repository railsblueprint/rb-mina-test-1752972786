# Google reCAPTCHA Integration

The Plus edition includes Google reCAPTCHA v2 integration to protect forms from spam and abuse.

## Overview

reCAPTCHA is integrated into critical forms throughout the application to verify that users are human. This helps prevent automated spam submissions and brute force attacks.

## Protected Forms

By default, reCAPTCHA is enabled on:
- User registration (`/users/register`)
- Contact forms (`/contacts`)
- Password reset requests
- Any custom forms using the reCAPTCHA helper

## Configuration

### 1. Obtain reCAPTCHA Keys

1. Visit [Google reCAPTCHA Admin](https://www.google.com/recaptcha/admin)
2. Register your site
3. Choose reCAPTCHA v2 - "I'm not a robot" Checkbox
4. Add your domains (localhost for development)
5. Copy the Site Key and Secret Key

### 2. Configure Rails Credentials

Add your reCAPTCHA keys to Rails credentials:

```bash
rails credentials:edit
```

Add the following structure:

```yaml
recaptcha:
  site_key: your_site_key_here
  secret_key: your_secret_key_here
```

For environment-specific keys:

```bash
rails credentials:edit --environment production
```

### 3. Environment Variables (Alternative)

You can also use environment variables:

```bash
export RECAPTCHA_SITE_KEY=your_site_key_here
export RECAPTCHA_SECRET_KEY=your_secret_key_here
```

## Usage

### In Views

Add reCAPTCHA to any form using the helper:

```erb
<%= form_with model: @model do |f| %>
  <!-- form fields -->
  
  <% if resource.should_validate_recaptcha? %>
    <div class="form-group">
      <%= recaptcha_tags %>
    </div>
  <% end %>
  
  <%= f.submit %>
<% end %>
```

For Bootstrap forms:

```erb
<%= bootstrap_form_for @model do |f| %>
  <!-- form fields -->
  
  <% if resource.should_validate_recaptcha? %>
    <div class="col-12">
      <%= recaptcha f %>
    </div>
  <% end %>
  
  <%= f.submit %>
<% end %>
```

### In Controllers

Verify reCAPTCHA in your controller actions:

```ruby
class ContactsController < ApplicationController
  def create
    if verify_recaptcha
      # Process the form
      @contact = Contact.create(contact_params)
      redirect_to root_path, notice: "Message sent!"
    else
      # reCAPTCHA failed
      @contact = Contact.new(contact_params)
      flash.now[:alert] = "Please verify you're not a robot"
      render :new
    end
  end
end
```

### Conditional Validation

The User model includes logic to require reCAPTCHA only for new registrations:

```ruby
class User < ApplicationRecord
  def should_validate_recaptcha?
    new_record? && Rails.configuration.recaptcha_enabled
  end
end
```

## Configuration Options

### Disable in Development

To disable reCAPTCHA in development:

```ruby
# config/environments/development.rb
config.recaptcha_enabled = false
```

### Custom Threshold

Adjust the score threshold for reCAPTCHA v3 (if upgraded):

```ruby
# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.minimum_score = 0.5
end
```

### Proxy Support

If behind a proxy:

```ruby
Recaptcha.configure do |config|
  config.proxy = 'http://proxy.example.com:8080'
end
```

## Testing

### Bypass in Tests

reCAPTCHA is automatically disabled in the test environment. To manually control:

```ruby
# spec/support/recaptcha.rb
RSpec.configure do |config|
  config.before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
  end
end
```

### Test Specific Scenarios

Test both success and failure cases:

```ruby
describe "registration" do
  it "succeeds with valid reCAPTCHA" do
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
    # test registration
  end
  
  it "fails with invalid reCAPTCHA" do
    allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    # test failure
  end
end
```

## Styling

The reCAPTCHA widget can be styled with CSS:

```scss
// app/assets/stylesheets/components/_recaptcha.scss
.g-recaptcha {
  margin: 1rem 0;
  
  @media (max-width: 480px) {
    transform: scale(0.9);
    transform-origin: 0 0;
  }
}
```

## Troubleshooting

### Common Issues

1. **"ERROR for site owner: Invalid site key"**
   - Verify your site key is correct
   - Ensure you're using the right key for the environment
   - Check that the domain is registered in reCAPTCHA admin

2. **reCAPTCHA not appearing**
   - Check JavaScript console for errors
   - Verify the reCAPTCHA script is loading
   - Ensure no Content Security Policy is blocking Google domains

3. **Always failing verification**
   - Check your secret key is correct
   - Verify server time is synchronized
   - Check firewall rules allow outbound HTTPS to Google

### Debug Mode

Enable debug logging:

```ruby
# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.debug = Rails.env.development?
end
```

## Best Practices

1. **Don't expose keys**: Never commit reCAPTCHA keys to version control
2. **Use environment-specific keys**: Different keys for development/staging/production
3. **Graceful degradation**: Handle cases where reCAPTCHA fails to load
4. **User experience**: Provide clear error messages when validation fails
5. **Monitor usage**: Check reCAPTCHA analytics for suspicious patterns