module Pages
  class UpdateCommand < BaseCommand
    include BuildFromObject

    adapter Page

    attribute :id, Types::String

    attribute :url, Types::String
    attribute :title, Types::String
    attribute :body, Types::String
    attribute :seo_title, Types::String
    attribute :seo_keywords, Types::String
    attribute :seo_description, Types::String
    attribute :icon, Types::String
    attribute :active, Types::String | Types::Bool
    attribute :show_in_sidebar, Types::String | Types::Bool

    validates :id, :resource, :name, presence: true

    validates :name, :reference, :subdomain, presence: true

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
