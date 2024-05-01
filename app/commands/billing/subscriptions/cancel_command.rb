module Billing::Subscriptions
  class CancelCommand < BaseCommand
    attribute :id, Types::String
    attribute :cuurent_user, Types::Nominal(User)

    def process
      cancel_stripe_subscription
      subscription.update(cancelled: true)
    end

    memoize def subscription
      Billing::Subscription.find(id)
    end

    def cancel_stripe_subscription
      Stripe::Subscription.update(subscription.stripe_id, { cancel_at_period_end: true })
    end
  end
end
