module Users
  class CreateCommand < BaseCommand
    include BuildFromObject

    adapter User

    attribute :url, Types::String
    attribute :title, Types::String
    attribute :body, Types::String
    attribute :seo_title, Types::String
    attribute :seo_keywords, Types::String
    attribute :seo_description, Types::String
    attribute :icon, Types::String
    attribute :active, Types::String
    attribute :show_in_sidebar, Types::String

    validates :name, presence: true

    attribute :current_user, Types::Nominal(User)

    def process
      create_resource
      # log_changes
    end

    def create_resource
      @resource = adapter.create(attributes.without(:current_user))
    end



    def log_changes
      changes = user.previous_changes.except("updated_at")
      return if changes.blank?

      UserLog.create(user_id: current_user&.id, type: "updated", topics: [user], data: changes)
    end

    def broadcast_ok
      broadcast :ok, @resource
    end
  end
end
