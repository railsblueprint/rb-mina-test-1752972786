module Settings
  class UpdateCommand < BaseCommand
    include BuildFromObject

    adapter Setting

    attribute :id, Types::String


    attribute :alias, Types::String
    attribute :type, Types::String
    attribute :description, Types::String
    attribute :value, Types::String
    attribute :set, Types::String

    validates :id, :resource, presence: true


    attribute :current_user, Types::Nominal(User)

    def process
      update_resource
      # log_changes
    end

    def update_resource
      resource.update(attributes.without(:current_user, :id))
    end

    memoize def resource
      adapter.find_by(id:)
    end

    def broadcast_ok
      broadcast :ok, resource
    end
  end
end
