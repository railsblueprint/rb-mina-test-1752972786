class CreateMailTemplates1723578324 < ActiveRecord::Migration[7.0]
  def up
    unless MailTemplate.where("alias": "subscription_created_to_user").any?
      MailTemplate.create(
        "alias":     "subscription_created_to_user",
        subject:      "[{% t platform.name %}] You have subscribed to {{subscription.type}}",
        body:         "<p>Congratulations, {{user.first_name}}!</p>

<p>You successfully subscribed to {{subscription.type}}. Now you will be able to see subscribers-only posts in our blog</p>
{% unless user.confirmed %}
<p>We have created a new account for you</p>
<p>Please confirm your email here: <a href=\"{{user.confirmation_url}}\">{{user.confirmation_url}}</a></p>

<p> Your login information:<br/>
Login: {{user.email}}<br/>
Password: {{user.password}}<br/>  
</p>
<p>You will be asked to change your password after first login</p>
{% endunless %}",
        layout:       "clean_html",
      )
    end
    unless MailTemplate.where("alias": "subscription_created_to_owner").any?
      MailTemplate.create(
        "alias":     "subscription_created_to_owner",
        subject:      "[{% t platform.name %}] New subscriber for {{subscription.type}}",
        body:         "<p>Congratulations!</p>

<p>You've got a new subscriber for {{subscription.type}}. 
More details on <a href=\"{{subscription.url}}\" target=\"_blank\">subscription page</a>.</p>
",
        layout:       "clean_html",
      )
    end

  end

  def down
  end
end
