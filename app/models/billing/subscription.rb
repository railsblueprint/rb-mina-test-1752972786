module Billing
  class Subscription < ApplicationRecord
    include PgSearch::Model
    # pg_search_scope :search, against: [:name, :reference, :description]
    belongs_to :user
    belongs_to :subscription_type, class_name: "Billing::SubscriptionType"

    scope :active, -> { where(start_date: [..Date.current], renew_date: [Date.tomorrow..]) }
    scope :expired, -> { where(renew_date: [..Date.current]) }

    def name
      [user.full_name, subscription_type.name].join(": ")
    end
  end
end
