module Users
  module Attributes
    extend ActiveSupport::Concern

    included do
      attribute :first_name, Types::String
      attribute :last_name, Types::String
      attribute :job, Types::String
      attribute :company, Types::String

      attribute :phone, Types::String
      attribute :email, Types::String
      attribute :country, Types::String
      attribute :address, Types::String
      attribute :about, Types::String

      attribute :twitter_profile, Types::String
      attribute :facebook_profile, Types::String
      attribute :instagram_profile, Types::String
      attribute :linkedin_profile, Types::String

      attribute :role_ids, Types::Array
    end
  end
end