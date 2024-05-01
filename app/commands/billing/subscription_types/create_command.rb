module Billing::SubscriptionTypes
  class CreateCommand < Crud::CreateCommand
    include Attributes

    validate :reference_unique_in_stripe

    def process
      super
      create_in_stripe
    end

    def reference_unique_in_stripe
      return if errors[:reference].present?

      Stripe::Plan.retrieve(reference)

      errors.add(:reference, :taken_in_stripe)
    rescue Stripe::InvalidRequestError
    end

    def create_in_stripe
      Stripe::Plan.create(stripe_plan_attributes)
    end

    def stripe_plan_attributes
      {
        id:             reference,
        product:        { name: },
        amount:         @resource.price_in_cents,
        currency:       "eur",
        interval:       "year",
        interval_count: 1
      }
    end
  end
end
