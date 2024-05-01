module Billing::Subscriptions
  class RenewCommand < BaseCommand
    attribute :id, Types::String
    attribute :cuurent_user, Types::Nominal(User)

    def process
      subscription.update(cancelled: false)
    end

    memoize def subscription
      Billing::Subscription.find(id)
    end
  end
end
