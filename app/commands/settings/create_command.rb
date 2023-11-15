module Settings
  class CreateCommand < BaseCommand
    include BuildFromObject
    include UniquenessValidator

    adapter Setting

    attribute :current_user, Types::Nominal(User)

    attribute :alias, Types::String
    attribute :type, Types::String
    attribute :description, Types::String
    attribute :value, Types::String
    attribute :set, Types::String

    validates :alias, :type, :description, presence: true
    validates :alias, uniqueness: true

    def process
      create_resource
    end

    def create_resource
      @resource = adapter.create!(attributes.without(:current_user))
    end

    def broadcast_ok
      broadcast :ok, @resource
    end
  end
end
