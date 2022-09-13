class ContactUsCommand < BaseCommand
  attribute :name
  attribute :email
  attribute :subject
  attribute :message

  validates_presence_of :name, :email, :subject, :message

  def process
    send_notification
  end

  def send_notification
    TemplateMailer.email(:contact_form_message, {
      to:           Setting.contact_form_receivers,
      reply_to:     email,
      subject:      subject,
      sender_name:  name,
      sender_email: email,
      message:      message

    }).deliver_later
  end
end
