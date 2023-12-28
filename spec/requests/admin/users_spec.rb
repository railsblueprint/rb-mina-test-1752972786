RSpec.describe "Admin Users" do
  options = { resource: :users, model: User, has_filters: true }
  let(:admin) { create(:user, :superadmin) }

  include_examples "admin crud controller", options
  include_examples "admin crud controller paginated index", options
  include_examples "admin crud controller show resource", options

  describe "GET /admin/users" do
    let!(:testuser) { create(:user, first_name: "test") }
    let!(:otheruser) { create(:user, first_name: "other") }

    before do
      sign_in admin
      get "/admin/users/?q=test"
    end

    it "returns a 200 status code" do
      expect(response).to be_successful
    end

    it "finds user", :aggregate_failures do
      expect(response.body).to include(testuser.last_name)
      expect(response.body).not_to include(otheruser.last_name)
    end
  end

  describe "GET /admin/users/lookup" do
    let!(:testuser) { create(:user, first_name: "test") }

    before do
      sign_in admin
      get "/admin/users/lookup?q=test"
    end

    it "returns a 200 status code" do
      expect(response).to be_successful
    end

    it "renders json" do
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end

    it "finds user and renders json" do
      expect(response.parsed_body).to eq({
        results:    [{ id: testuser.id, text: testuser.full_name }],
        pagination: { more: false }
      }.deep_stringify_keys)
    end
  end

  describe "POST /admin/users/:id/impersonate" do
    let!(:testuser) { create(:user, first_name: "test") }
    let(:admin) { create(:user, :superadmin) }

    before do
      sign_in admin
      post "/admin/users/#{testuser.id}/impersonate"
    end

    it "redirects to home page" do
      expect(response).to redirect_to(root_path)
    end

    it "shows success message" do
      expect(flash[:success]).to be_present
    end

    it "rememebrs impersonator" do
      expect(session[:impersonator_id]).to eq(admin.id)
    end
  end
end
