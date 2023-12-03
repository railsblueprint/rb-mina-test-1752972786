require "rails_helper"

RSpec.describe "Posts page", type: :request do
  let(:user) { create(:user) }


  describe "GET /posts" do
    context "when logged in" do
      before do
        sign_in user
        get "/posts"
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when not logged in" do
      let!(:resources) { create_list(:post, 10) }

      it "returns http success" do
        get "/posts"
        expect(response).to have_http_status(:success)
      end

      it "render posts" do
        get "/posts"
        expect(response.body).to have_tag(".card.post", count: 5)
      end
    end
  end

  xdescribe "POST /contacts" do
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

    it "sends a confirmation email" do
      expect {  post "/contacts", params: }.to have_enqueued_mail
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