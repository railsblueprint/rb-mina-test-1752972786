RSpec.describe "Admin Posts", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin) }

  xdescribe "GET /admin/posts" do
    it "return a list of posts" do
      sign_in admin

      get [:admin, :posts]

      expect(response).to have_http_status(:ok)

      # post "/widgets", :params => { :widget => {:name => "My Widget"} }
      # expect(response).to redirect_to(assigns(:widget))
      # follow_redirect!
      # expect(response).to render_template(:show)
      # expect(response.body).to include("Widget was successfully created.")
    end
  end

end
