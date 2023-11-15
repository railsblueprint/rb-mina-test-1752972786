module Tenant
  class DestroyCommand < BaseCommand
    adapter Tenant

    attribute :id, Types::String

    validates :id, :resource, presence: true

    attribute :current_user, Types::Nominal(User)

    def process
      destroy_resource
      # log_changes
    end

    def destroy_resource
      resource.destroy || abort_command
    end

    memoize def resource
      adapter.find_by(id:)
    end

    def broadcast_ok
      broadcast :ok, resource
    end
  end
end
