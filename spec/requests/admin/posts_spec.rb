require "rails_helper"

RSpec.describe "Admin Posts", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:moderator) { create(:user, :moderator) }
  let!(:page_size) {  Post.default_per_page }

  describe "GET /admin/posts" do
    before do
      sign_in admin

      get "/admin/posts"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    it "includes a link to create a new post" do
      expect(response.body).to have_tag("a.btn.btn-primary", seen: "Create")
    end

    context "when user is not logged" do
      before do
        sign_out :user

        get "/admin/posts"
      end

      it "redirects to the login page" do
        expect(response).to redirect_to("/users/login")
        expect(flash[:alert]).to match(/You need to sign in or sign up before continuing./)
      end
    end

    context "when user is not authorized" do
      before do
        sign_in moderator

        get "/admin/posts"
      end

      it "redirects to the home page" do
        expect(response).to redirect_to("/")
        expect(flash[:alert]).to match(/You cannot access this page/)
      end
    end

    context "when there are no posts" do
      it "says there are no posts" do
        expect(response.body).to include("No posts found")
      end

      it "includes a link to create a new post" do
        expect(response.body).to have_tag("a.btn.btn-primary", seen: "Create")
      end

      it "2 header lines" do
        expect(response.body).to have_tag("li.item.item-container", count: 2)
      end

      it "renders search form" do
        expect(response.body).to have_form "/admin/posts", :get

      end
    end

    context "when there is less than one page" do
      let!(:posts) { create_list(:post, 10) }

      before do
        sign_in admin

        get "/admin/posts"
      end

      it "renders all" do
        expect(response.body).to include("Displaying <b>all 10</b> posts")
        expect(response.body).to have_tag('ul', class: "pagination")
        expect(response.body).to have_tag("li.item.item-container", count: 12)
      end

      it "renders action buttons" do
        # expect(response.body).to have_tag("a", seen: "Details", count: 10)
        expect(response.body).to have_tag("a", seen: "Delete", count: 10)
      end

      it "renders posts" do
        posts.each do |post|
          expect(response.body).to have_tag("div.attribute", seen: post.user.full_name, count: 1)
          expect(response.body).to have_tag("div.attribute", seen: post.title, count: 1)
        end
      end
    end

    context "when there is more than one page" do
      let!(:posts) { create_list(:post, page_size + 15) }

      before do
        sign_in admin

        get "/admin/posts"
      end

      it "renders first page" do
        expect(response.body).to include("Displaying posts <b>1&nbsp;-&nbsp;#{page_size}</b> of <b>#{page_size + 15}</b> in total")
        expect(response.body).to have_tag('ul', class: "pagination")

        expect(response.body).to have_tag("li.item.item-container", count: page_size + 2)
      end
    end

    context "when searching by title" do
      let!(:posts) { create_list(:post, page_size + 15) }
      let!(:post) {create(:post, title: "___SEARCH__TERM___")}
      before do
        sign_in admin

        get "/admin/posts?q=___SEARCH__TERM___"
      end

      it "finds post" do
        expect(response.body).to include("Displaying <b>1</b> post")

        expect(response.body).to have_tag("div.attribute", seen: post.title, count: 1)
        expect(response.body).to have_tag("li.item.item-container", count: 3)
      end
    end

    context "when searching by user" do
      let!(:posts) { create_list(:post, page_size + 15) }
      let!(:post) {create(:post)}
      before do
        sign_in admin

        get "/admin/posts?user_id=#{post.user.id}"
      end

      it "finds post" do
        expect(response.body).to include("Displaying <b>1</b> post")

        expect(response.body).to have_tag("div.attribute", seen: post.title, count: 1)
        expect(response.body).to have_tag("li.item.item-container", count: 3)
      end
    end
  end

  describe "GET /admin/posts/:id" do
    let!(:post) { create(:post) }

    before do
      sign_in admin

      get "/admin/posts/#{post.id}"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(post.title)
      expect(response.body).to include(post.body.to_s)
    end

    it "includes link to the user" do
      expect(response.body).to have_tag("a", with: {href: "/admin/users/#{post.user_id}"})
      expect(response.body).to include(post.user.full_name)
    end

    it "renders action buttons" do
      expect(response.body).to have_tag("a", seen: "Edit")
      expect(response.body).to have_tag("a", seen: "Delete")
    end
  end

  describe "GET /admin/posts/:id/edit" do
    let!(:post) { create(:post) }

    before do
      sign_in admin

      get "/admin/posts/#{post.id}/edit"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_form "/admin/posts/#{post.id}", :post
    end

    it "renders action buttons" do
      expect(response.body).to have_tag("input", type: "submit", value: "Save")
      expect(response.body).to have_tag("a", seen: "Cancel")
      expect(response.body).to have_tag("a", seen: "Delete")
    end
  end

  describe "PATCH /admin/posts/:id" do
    let!(:post) { create(:post) }

    let(:params) {
      {
        post: {
          title: "new title",
          body: post.body.to_s,
          user_id: post.user_id
        }
      }
    }

    before do
      sign_in admin

      patch "/admin/posts/#{post.id}", params: params
    end

    it "redirects to edit page" do
      expect(response).to redirect_to("/admin/posts/#{post.id}/edit")
      expect(flash[:success]).to match(/Successfully updated/)
    end

    it "updates the post" do
      expect(post.reload.title).to eq("new title")
    end
  end

  describe "GET /admin/posts/new" do
    let!(:post) { create(:post) }

    before do
      sign_in admin

      get "/admin/posts/new"
    end

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_form "/admin/posts", :post
    end

    it "renders action buttons" do
      expect(response.body).to have_tag("input", type: "submit", value: "Save")
      expect(response.body).to have_tag("a", seen: "Cancel")
    end
  end

  describe "POST /admin/posts" do
    let!(:user) { create(:user) }

    let(:params) {
      {
        post: {
          title: "new title",
          body: "new body",
          user_id: user.id
        }
      }
    }

    before do
      sign_in admin

      post "/admin/posts", params: params
    end

    it "renders successfully" do
      post = user.posts.first

      expect(response).to redirect_to("/admin/posts/#{post.id}/edit")
      expect(flash[:success]).to match(/Successfully created/)
    end

    it "creates a new post" do
      expect(user.posts.count).to eq(1)
    end
  end



  describe "DELETE /admin/posts/:id" do
    let!(:post) { create(:post) }

    before do
      sign_in admin

      delete "/admin/posts/#{post.id}"
    end

    it "renders successfully" do
      expect(response).to redirect_to("/admin/posts")
      expect(flash[:notice]).to match(/Successfully deleted/)
    end
  end

end
