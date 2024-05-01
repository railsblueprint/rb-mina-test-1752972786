module Billing::Subscriptions
  class UpdateCommand < Crud::UpdateCommand
    include Attributes

    def process
      update_resource
      # update_stripe_customer
    end

    # def update_stripe_customer
    #   response = Stripe::Customer.update(resource.stripe_id, stipe_attributes)
    #   pp response
    # rescue Stripe::InvalidRequestError => e
    #   errors.add(:base, e.message)
    #   abort_command
    # end
  end
end
