module Crud
  class UpdateCommand < BaseCommand
    include BuildFromObject

    attribute :id, Types::String

    validates :id, :resource, presence: true

    attribute :current_user, Types::Nominal(User)

    def process
      update_resource
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

    def persisted?
      true
    end
  end
end
