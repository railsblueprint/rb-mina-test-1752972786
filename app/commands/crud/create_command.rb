module Crud
  class CreateCommand < BaseCommand
    attribute :current_user, Types::Nominal(User)

    def process
      create_resource
    end

    def create_resource
      @resource = adapter.create(attributes.without(:current_user))
    end

    def broadcast_ok
      broadcast :ok, @resource
    end
  end
end
