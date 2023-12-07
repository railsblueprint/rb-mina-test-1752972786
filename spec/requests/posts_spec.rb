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
      let!(:resources) { create_list(:post, 7) }

      it "returns http success" do
        get "/posts"
        expect(response).to have_http_status(:success)
      end

      it "render first 5 posts" do
        get "/posts"
        expect(response.body).to have_tag(".card.post", count: 5)
      end

      it "render last 2 posts" do
        get "/posts?page=2"
        expect(response.body).to have_tag(".card.post", count: 2)
      end
    end

    context "when logged as post author" do
      let(:user) { create(:user) }
      let!(:resources) { create_list(:post, 5, user:) }

      before do
        sign_in user
        get "/posts"
      end

      it "shows control buttons" do
        get "/posts"
        expect(response.body).to have_tag(".card.post a", text: "Edit", count: 5)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 5)
      end
    end

    context "when logged as moderator" do
      let(:moderator) { create(:user, :moderator) }
      let!(:resources) { create_list(:post, 5) }

      before do
        sign_in moderator
        get "/posts"
      end

      it "shows control buttons" do
        expect(response.body).to have_tag(".card.post a", text: "Edit", count: 5)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 5)
      end
    end
  end

  describe "GET /posts/new" do
    let!(:user) { create(:user) }

    context "when not logged in" do
      before do
        sign_out :user
        get "/posts/new"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows flash message" do
        expect(flash[:alert]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when logged in" do
      before do
        sign_in user
        get "/posts/new"
      end

      it "renders ok" do
        expect(response).to be_successful
      end

      it "renders form" do
        expect(response.body).to have_form("/posts", :post)
      end
    end
  end

  describe "POST /posts" do
    let!(:user) { create(:user) }
    let(:params) { { post: { title: "title", body: "content" } }}

    context "when not logged in" do
      before do
        post "/posts", params:
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows flash message" do
        expect(flash[:alert]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when logged in" do
      before do
        sign_in user
        post "/posts", params:
      end

      it "redirect to new post" do
        expect(response).to redirect_to /\/posts\/.+\/edit/
      end

      it "creates a new post" do
        expect(Post.count).to eq(1)
      end

    end
  end

  describe "GET /posts/:id" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user:) }
    let(:params) { { post: { title: "title", body: "content" } }}

    context "when not logged in" do
      before do
        get "/posts/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body" do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "does not show control buttons" do
        expect(response.body).to_not have_tag(".card.post a", text: "Edit", count: 1)
        expect(response.body).to_not have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end

    context "when logged in as a different user" do
      let(:other_user) { create(:user) }
      before do
        sign_in other_user
        get "/posts/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body" do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "does not show control buttons" do
        expect(response.body).to_not have_tag(".card.post a", text: "Edit", count: 1)
        expect(response.body).to_not have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end


    context "when logged as author" do
      before do
        sign_in user
        get "/posts/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body" do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "shows control buttons" do
        expect(response.body).to have_tag(".card.post a", text: "Edit", count: 1)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end

    context "when logged as moderator" do
      let(:moderator) { create(:user, :moderator) }

      before do
        sign_in moderator
        get "/posts/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end
      before do
        sign_in moderator
        get "/posts/#{post.id}"
      end

      it "renders the post" do
        expect(response).to be_successful
      end

      it "shows the body" do
        expect(response.body).to include(ERB::Util.h(post.title))
        expect(response.body).to include(post.body.to_s)
      end

      it "shows control buttons" do
        expect(response.body).to have_tag(".card.post a", text: "Edit", count: 1)
        expect(response.body).to have_tag(".card.post a", text: /Delete/, count: 1)
      end
    end
  end


  describe "GET /posts/:id/edit" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user:) }
    let(:params) { { post: { title: "title", body: "content" } }}

    context "when not logged in" do
      before do
        get "/posts/#{post.id}/edit"
      end

      it "redirects to login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as a different user" do
      let(:other_user) { create(:user) }
      before do
        sign_in other_user
        get "/posts/#{post.id}/edit"
      end

      it "redirects to home page" do
        expect(response).to redirect_to(root_path)
      end
    end


    context "when logged as author" do
      before do
        sign_in user
        get "/posts/#{post.id}/edit"
      end

      it "renders ok" do
        expect(response).to be_successful
      end

      it "shows the form" do
        expect(response.body).to have_form("/posts/#{post.id}", :post)
      end
    end

    context "when logged as moderator" do
      let(:moderator) { create(:user, :moderator) }

      before do
        sign_in moderator
        get "/posts/#{post.id}/edit"
      end

      it "renders ok" do
        expect(response).to be_successful
      end

      it "shows the form" do
        expect(response.body).to have_form("/posts/#{post.id}", :post)
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