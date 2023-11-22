module MailTemplates
  module Attributes
    extend ActiveSupport::Concern
    include Crud::Attributes
    include UniquenessValidator

    included do
      attribute :alias, Types::String
      attribute :layout, Types::String
      attribute :subject, Types::String
      attribute :body, Types::String | Types::Nominal(ActionText::RichText)

      validates :alias, :layout, presence: true
    end
  end
end
