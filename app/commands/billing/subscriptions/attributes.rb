module Billing::Subscriptions
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes

    included do
      attribute :user_id, Types::String
      attribute :subscription_type_id, Types::String
      attribute :reference, Types::String
      attribute :cancelled, Types::Bool
      attribute :start_date, Types::Date
      attribute :renew_date, Types::Date
    end
  end
end
