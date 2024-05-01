module Billing::SubscriptionTypes
  class UpdateCommand < Crud::UpdateCommand
    include Attributes

    def process
      super
      update_in_stripe
    end

    def update_in_stripe
      Stripe::Price.update(reference, stripe_plan_attributes)
    end

    def stripe_plan_attributes
      {
        amount: resource.price_in_cents
      }
    end
  end
end
