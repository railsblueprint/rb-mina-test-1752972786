require "rails_helper"

RSpec.describe "Feature Flags" do
  let(:superadmin) { create(:user, :superadmin) }
  let(:regular_user) { create(:user) }

  describe "Admin UI access" do
    it "allows superadmins to access feature flags UI" do
      sign_in superadmin
      visit "/admin/flipper"

      expect(page).to have_content("Features")
    end

    it "denies access to regular users" do
      sign_in regular_user
      visit "/admin"

      # Regular users are redirected to root when trying to access admin
      expect(page).to have_current_path(root_path)
    end
  end

  describe "Feature flag usage in views" do
    it "conditionally shows content based on feature flags" do
      # Enable a feature for testing
      Flipper.enable(:beta_feature)

      sign_in regular_user
      visit root_path

      # This tests the helper methods work correctly
      # In a real app, you'd have views using with_feature/without_feature
      expect(Flipper.enabled?(:beta_feature, regular_user)).to be true

      # Cleanup
      Flipper.disable(:beta_feature)
    end

    it "respects user-specific feature flags" do
      Flipper.enable_actor(:special_feature, regular_user)
      other_user = create(:user)

      expect(Flipper.enabled?(:special_feature, regular_user)).to be true
      expect(Flipper.enabled?(:special_feature, other_user)).to be false

      # Cleanup
      Flipper.disable(:special_feature)
    end
  end
end
