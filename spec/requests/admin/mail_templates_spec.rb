RSpec.describe "Admin Mail Templates", type: :request do
  include_examples "admin crud controller", {resource: :mail_templates, model: MailTemplate, prefix: "config"}
  include_examples "admin crud controller empty search", {resource: :mail_templates, model: MailTemplate, prefix: "config"}

  describe "GET /admin/config/mail_templates/:id/preview" do
    let(:mail_template) {create(:mail_template)}
    let(:admin) { create(:user, :superadmin) }

    before do
      sign_in admin
      get "/admin/config/mail_templates/#{mail_template.id}/preview"
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end