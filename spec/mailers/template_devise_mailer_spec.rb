RSpec.describe TemplateDeviseMailer, type: :mailer do
  let(:user) { create(:user) }

  let(:token) { SecureRandom.uuid }

  describe "#confirmation_instructions" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:confirmation_instructions, {
        to:               user.email,
        user:,
        confirmation_url: String
      }).and_return(double(deliver_later: true))

      TemplateDeviseMailer.confirmation_instructions(user, token).deliver
    end
  end

  describe "#reset_password_instructions" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:reset_password_instructions, {
        to:        user.email,
        user:,
        token:,
        reset_url: String
      }).and_return(double(deliver_later: true))

      TemplateDeviseMailer.reset_password_instructions(user, token).deliver
    end
  end

  describe "#unlock_instructions" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:unlock_instructions, {
        to:         user.email,
        user:,
        token:,
        unlock_url: String
      }).and_return(double(deliver_later: true))

      TemplateDeviseMailer.unlock_instructions(user, token).deliver
    end
  end

  describe "#email_changed" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:email_changed, {
        to:   user.email,
        user:
      }).and_return(double(deliver_later: true))

      TemplateDeviseMailer.email_changed(user).deliver
    end
  end

  describe "#password_change" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:password_change, {
        to:   user.email,
        user:
      }).and_return(double(deliver_later: true))

      TemplateDeviseMailer.password_change(user).deliver
    end
  end
end
