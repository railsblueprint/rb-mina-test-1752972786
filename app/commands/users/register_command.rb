module Users
  class RegisterCommand < BaseCommand
    include RecaptchaValidator

    attribute :first_name, Types::String
    attribute :last_name, Types::String
    attribute :email, Types::String
    attribute :password, Types::String
    attribute :password_confirmation, Types::String

    validates :first_name, :last_name, :email, :password, :password_confirmation, presence: true
    validate_recaptcha action: "registration", if: -> { should_validate_recaptcha? }

    def should_validate_recaptcha?
      recaptcha_configured? && (AppConfig.recaptcha&.show&.on_registration)
    end

    def process
      @user = User.create(user_attrubutes)
      return @user if @user.persisted?

      errors.copy!(@user.errors)
      abort_command
    end

    def user_attrubutes
      attributes.slice(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def broadcast_ok
      broadcast :ok, @user
    end
  end
end
