module Billing::Subscriptions
  class CreateCommand < BaseCommand
    include Rails.application.routes.url_helpers

    attribute :current_user, Types::Nominal(User)
    attribute :reference, Types::String

    def process
      create_stripe_customer
      create_session
    end

    def create_session
      @session = Stripe::Checkout::Session.create(
        {
          mode:        "subscription",
          customer:    current_user.stripe_id,
          line_items:  [{
            quantity: 1,
            price:    subscription_type.reference
          }],
          success_url: subscribe_success_url(plan: subscription_type.reference),
          cancel_url:  subscribe_cancel_url
        }
      )
    end

    def create_stripe_customer
      return if current_user.stripe_id.present?

      stripe_customer = Stripe::Customer.create(email: current_user.email)
      current_user.update(stripe_id: stripe_customer.id)
    end

    def subscription_type
      Billing::SubscriptionType.find_by(reference:)
    end

    def broadcast_ok
      broadcast :ok, @session
    end
  end
end
