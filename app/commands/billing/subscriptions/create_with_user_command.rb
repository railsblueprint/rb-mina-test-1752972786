module Billing::Subscriptions
  class CreateWithUserCommand < BaseCommand
    include RecaptchaValidator
    include UniquenessValidator

    include Rails.application.routes.url_helpers
    adapter User

    attribute :first_name, Types::String
    attribute :last_name, Types::String
    attribute :email, Types::String

    attribute :reference, Types::String
    validates :first_name, :last_name, :email, presence: true
    validates :email, uniqueness: true

    validate_recaptcha action: "registration", if: -> { should_validate_recaptcha? }

    def process
      create_user
      create_stripe_customer
      create_session
    end

    def should_validate_recaptcha?
      recaptcha_configured? && AppConfig.recaptcha&.show&.on_registration
    end

    def create_user
      @user = User.create(user_attributes)
      return if @user.persisted?

      errors.copy!(@user.errors)
      abort_command
    end

    def user_attributes
      {
        skip_confirmation_notification: true,
        password: SecureRandom.hex(10),
        first_name:, last_name:, email:
      }
    end

    def current_user
      @user
    end

    def create_session
      @session = Stripe::Checkout::Session.create(
        {
          mode:        "subscription",
          customer:    current_user.stripe_id,
          line_items:  [{
            quantity: 1,
            price:    subscription_type.reference
          }],
          success_url: subscribe_success_url(plan: subscription_type.reference),
          cancel_url:  subscribe_cancel_url
        }
      )
    end

    def create_stripe_customer
      return if current_user.stripe_id.present?

      stripe_customer = Stripe::Customer.create(email: current_user.email)
      current_user.update(stripe_id: stripe_customer.id)
    end

    def subscription_type
      Billing::SubscriptionType.find_by(reference:)
    end

    def broadcast_ok
      broadcast :ok, @session
    end
  end
end
