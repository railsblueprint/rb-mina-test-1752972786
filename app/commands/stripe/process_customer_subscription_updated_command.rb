module Stripe
  class ProcessCustomerSubscriptionUpdatedCommand < BaseCommand
    attribute :event, Types::Nominal(Stripe::Event)
    validates :event, presence: true

    def process
      update_cancellation_status
    end

    memoize def stripe_subscription
      event.data.object
    end

    memoize def subscription
      ::Billing::Subscription.find_by(stripe_id: stripe_subscription.id)
    end

    def update_cancellation_status
      subscription.update(cancelled: stripe_subscription.cancel_at_period_end)
    end
  end
end
