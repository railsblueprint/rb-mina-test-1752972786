module Stripe
  class ProcessWebhookCommand < BaseCommand
    # attribute :event, Types::Nominal(Stripe::Event)

    validates :event, presence: true

    attribute :payload, Types::String
    attribute :signature, Types::String

    def process
      if processor.present?
        process_event
      else
        ::Rails.logger.warn("No processor for stripe event #{event_type}")
      end
    end

    def event
      Stripe::Webhook.construct_event(payload, signature, stripe_secret)
    end

    def process_event
      processor.call(event:)
    end

    def processor
      "Stripe::Process#{event_command_name}Command".safe_constantize
    end

    delegate :type, to: :event, prefix: true

    def event_command_name
      event_type.tr(".", "_").camelize
    end

    def stripe_secret
      AppConfig.stripe.signing_secret
    end
  end
end
