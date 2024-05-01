module Stripe
  class ProcessCustomerUpdatedCommand < BaseCommand
    attribute :event, Types::Nominal(Stripe::Event)
    validates :event, presence: true

    def process
      # pp event.data.object
    end
  end
end
