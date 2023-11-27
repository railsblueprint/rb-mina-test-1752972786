require "rails_helper"

RSpec.describe "Conacts page", type: :request do
  let(:user) { create(:user) }

  describe "GET /contacts" do
    context "when logged in" do
      before do
        sign_in user
        get "/contacts"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "prefills form" do
        expect(response.body).to have_tag "input", with: { name: "contact_us_command[name]", value: user.full_name }
        expect(response.body).to have_tag "input", with: { name: "contact_us_command[email]", value: user.email }
      end
    end

    context "when not logged in" do
      it "returns http success" do
        get "/contacts"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /contacts" do
    let(:params) {
      {
        contact_us_command: {
          name: "Test user",
          email: "mail@test.com",
          subject: "subject",
          message: "message"
        }
      }
    }
    before do
      post "/contacts", params:
    end

    it "returns http success" do
      expect(response).to redirect_to("/contacts")
    end

    context "with invalid params" do
      let(:params) {
        {
          contact_us_command: {
            name: "Test user",
          }
        }
      }
      before do
        post "/contacts", params:
      end

      it "returns http success" do
        expect(response).to be_successful
        expect(response).to render_template("new")
      end
    end

    context "as a trubostream" do
      let(:params) {
        {
          contact_us_command: {
            name: "Test user",
            email: "mail@test.com",
            subject: "subject",
            message: "message"
          }
        }
      }
      before do
        post "/contacts", as: :turbo_stream, params:
      end

      it "returns http success" do
        expect(response).to be_successful
        expect(response).to render_template(layout: false)
        expect(response.body).to include('<turbo-stream action="replace" target="frame_new_contact_us_command">')
      end

      context "with invalid params" do
        let(:params) {
          {
            contact_us_command: {
              name: "Test user",
            }
          }
        }
        before do
          post "/contacts", as: :turbo_stream, params:
        end
        it "returns http success" do
          expect(response).to be_successful
          expect(response).to render_template(layout: false)
          expect(response.body).to include('<turbo-stream action="replace" target="frame_new_contact_us_command">')
        end
      end
    end

  end
end