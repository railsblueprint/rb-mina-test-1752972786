class CreateSettings1723577983 < ActiveRecord::Migration[7.2]
  def up
    if Setting.where("key": "billing").any?
      Setting.where("key": "billing").update_all(
        type:        "section",
        section:     "",
        description: "Billing",
      )
    else
      Setting.create(
        "key":       "billing",
        type:        "section",
        section:     "",
        value:       "",
        description: "Billing",
      )
    end
    if Setting.where("key": "subscription_notification_email").any?
      Setting.where("key": "subscription_notification_email").update_all(
        type:        "string",
        section:     "billing",
        description: "Email for notifications of new subscriptions",
      )
    else
      Setting.create(
        "key":       "subscription_notification_email",
        type:        "string",
        section:     "billing",
        value:       "info@railsblueprint.com",
        description: "Email for notifications of new subscriptions",
      )
    end
    if Setting.where("key": "subscription_notify_on_created").any?
      Setting.where("key": "subscription_notify_on_created").update_all(
        type:        "boolean",
        section:     "billing",
        description: "Send notifications when new subscription is created",
      )
    else
      Setting.create(
        "key":       "subscription_notify_on_created",
        type:        "boolean",
        section:     "billing",
        value:       "1",
        description: "Send notifications when new subscription is created",
      )
    end
    if Setting.where("key": "stripe_test_mode").any?
      Setting.where("key": "stripe_test_mode").update_all(
        type:        "boolean",
        section:     "billing",
        description: "Stripe is in test mode",
      )
    else
      Setting.create(
        "key":       "stripe_test_mode",
        type:        "boolean",
        section:     "billing",
        value:       "1",
        description: "Stripe is in test mode",
      )
    end
    if Setting.where("key": "stripe_portal_url").any?
      Setting.where("key": "stripe_portal_url").update_all(
        type:        "string",
        section:     "billing",
        description: "Stipe portal url",
      )
    else
      Setting.create(
        "key":       "stripe_portal_url",
        type:        "string",
        section:     "billing",
        value:       "https://billing.stripe.com/p/login/test_bIY9BSeoGcxWcP6eUU",
        description: "Stipe portal url",
      )
    end

  end

  def down
  end
end
