class ContactUsCommand < BaseCommand
  include RecaptchaValidator

  attribute :name, Types::String
  attribute :email, Types::String
  attribute :subject, Types::String
  attribute :message, Types::String

  attribute :current_user, Types::Nominal(User)

  validates_presence_of :name, :email, :subject, :message

  validate_recaptcha action: "contacts", if: -> { should_validate_recaptcha? }

  def should_validate_recaptcha?
    recaptcha_configured? && current_user.blank? && AppConfig.recaptcha&.show&.on_contacts
  end

  def process
    send_notification
  end

  def send_notification
    TemplateMailer.email(:contact_form_message, {
      to:           AppConfig.contact_form_receivers,
      reply_to:     email,
      subject:,
      sender_name:  name,
      sender_email: email,
      message:

    }).deliver_later
  end
end
