module Stripe
  class ProcessCustomerSubscriptionCreatedCommand < BaseCommand
    include ::Rails.application.routes.url_helpers

    attribute :event, Types::Nominal(Stripe::Event)
    validates :event, presence: true

    def process
      create_subscription
      send_notification_to_user
      send_notification_to_owner
    end

    memoize def stripe_subscription
      event.data.object
    end

    def create_subscription
      @subscription = ::Billing::Subscription.create(subscription_attributes)
    end

    def subscription_attributes
      {
        stripe_id:            stripe_subscription.id,
        user_id:              user.id,
        start_date:           Date.current,
        renew_date:,
        cancelled:            false,
        subscription_type_id: subscription_type.id
      }
    end

    def renew_date
      Time.zone.at(stripe_subscription.current_period_end).to_date
    end

    memoize def user
      User.find_by(stripe_id: stripe_subscription.customer)
    end

    def subscription_type
      ::Billing::SubscriptionType.find_by(reference: stripe_subscription.plan.id)
    end

    def send_notification_to_owner
      return unless AppConfig.subscription_notify_on_created

      TemplateMailer.email(:subscription_created_to_owner, {
        to:           AppConfig.subscription_notification_email,
        subscription: {
          type: subscription_type.name,
          url:  admin_billing_subscription_url(@subscription)
        }
      }).deliver_later
    end

    def send_notification_to_user
      user.prepare_for_confitmation!

      TemplateMailer.email(:subscription_created_to_user, {
        to:           AppConfig.subscription_notification_email,
        subscription: {
          type: subscription_type.name
        },
        user:         user.to_liquid
      }).deliver_later
    end
  end
end
