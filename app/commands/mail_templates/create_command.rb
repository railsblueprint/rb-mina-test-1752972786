module MailTemplates
  class CreateCommand < BaseCommand
    include BuildFromObject
    include UniquenessValidator

    adapter MailTemplate

    attribute :current_user, Types::Nominal(User)

    attribute :alias, Types::String
    attribute :layout, Types::String
    attribute :subject, Types::String
    attribute :body, Types::String | Types::Nominal(ActionText::RichText)

    validates :alias, :layout, presence: true

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
