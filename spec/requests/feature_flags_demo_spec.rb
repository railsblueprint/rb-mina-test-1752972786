require "rails_helper"

RSpec.describe "Feature Flags Demo" do
  describe "GET /feature-flags-demo" do
    context "when not signed in" do
      it "shows the demo page" do
        get feature_flags_demo_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Feature Flags Demo")
        expect(response.body).to include("sign in")
      end

      it "shows disabled state for all features" do
        # Ensure features are disabled for this test
        Flipper.disable(:demo_feature)
        Flipper.disable(:beta_ui)

        get feature_flags_demo_path

        expect(response.body).to include("Feature Disabled")
        expect(response.body).to include("Standard UI")
        expect(response.body).not_to include("Feature Enabled!")
        expect(response.body).not_to include("New Beta UI")
      end
    end

    context "when signed in as regular user" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "shows user-specific feature states" do
        get feature_flags_demo_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Premium content is not available")
        expect(response.body).not_to include("Admin Controls")
      end

      context "with features enabled for user" do
        before do
          Flipper.enable(:demo_feature)
          Flipper.enable_actor(:premium_content, user)
        end

        after do
          Flipper.disable(:demo_feature)
          Flipper.disable(:premium_content)
        end

        it "shows enabled features" do
          get feature_flags_demo_path

          expect(response.body).to include("Feature Enabled!")
          expect(response.body).to include("Premium Content Available!")
          expect(response.body).not_to include("Feature Disabled")
        end
      end

      context "with beta features enabled" do
        before { Flipper.enable(:beta_ui) }
        after { Flipper.disable(:beta_ui) }

        it "shows beta UI" do
          get feature_flags_demo_path

          expect(response.body).to include("New Beta UI")
          expect(response.body).not_to include("Standard UI")
        end
      end
    end

    context "when signed in as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      context "with admin-only features" do
        before { Flipper.enable_group(:admin_tools, :admins) }
        after { Flipper.disable(:admin_tools) }

        it "shows admin features" do
          get feature_flags_demo_path

          expect(response.body).to include("Admin Tools")
          expect(response.body).to include("Advanced administrative features")
        end
      end
    end

    context "when signed in as superadmin" do
      let(:superadmin) { create(:user, :superadmin) }

      before { sign_in superadmin }

      it "shows admin controls" do
        get feature_flags_demo_path

        expect(response.body).to include("Admin Controls")
        expect(response.body).to include("Manage Feature Flags")
        expect(response.body).to include("/admin/flipper")
      end
    end
  end
end
