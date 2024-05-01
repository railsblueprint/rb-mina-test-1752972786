module Billing
  class SubscriptionType < ApplicationRecord
    enum :periodicity, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }

    include PgSearch::Model
    pg_search_scope :search, against: [:name, :reference, :description]

    scope :active, -> { where(active: true) }

    def price_in_cents
      (price * 100).to_i
    end
  end
end
