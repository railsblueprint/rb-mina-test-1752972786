require "rails_helper"

describe Admin::DashboardController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  subject { post :show }

  context "when logged in as admin" do
    describe "renders page show" do
      it "renders ok" do
        sign_in admin

        get :show
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when not logged in" do
    describe "renders page show" do
      it "renders ok" do
        expect( subject ).to redirect_to new_user_session_path
        expect( subject.request.flash[:alert] ).to_not be_nil
      end
    end
  end
end