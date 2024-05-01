module Billing::SubscriptionTypes
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes
    include UniquenessValidator

    included do
      attribute :name, Types::String
      attribute :description, Types::String
      attribute :reference, Types::String
      attribute :periodicity, Types::String | Types::Integer
      attribute :price, Types::Float | Types::String
      attribute :active, Types::String | Types::Bool

      validates :name, :reference, :periodicity, :price, presence: true
      validates :reference, uniqueness: true
    end
  end
end
