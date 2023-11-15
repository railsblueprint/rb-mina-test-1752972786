module MailTemplates
  class UpdateCommand < BaseCommand
    include BuildFromObject

    adapter MailTemplate

    attribute :id, Types::String


    attribute :alias, Types::String
    attribute :layout, Types::String
    attribute :subject, Types::String
    attribute :body, Types::String | Types::Nominal(ActionText::RichText)

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
