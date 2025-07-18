require "rails_helper"

RSpec.describe "Feature Flags Demo Page" do
  describe "Feature flag testing patterns" do
    it "demonstrates testing with feature flags disabled" do
      # Pattern 1: Ensure feature is disabled for test
      Flipper.disable(:demo_feature)

      visit feature_flags_demo_path

      # Verify fallback content is shown
      expect(page).to have_content("Feature Flags Demo")
      within(".card", text: "Basic Feature Toggle") do
        expect(page).to have_css(".alert-warning")
        expect(page).to have_content("Feature Disabled")
        expect(page).to have_no_content("Feature Enabled!")
      end
    end

    it "demonstrates testing with feature flags enabled" do
      # Pattern 2: Enable feature for test
      Flipper.enable(:demo_feature)

      visit feature_flags_demo_path

      # Verify feature content is shown
      within(".card", text: "Basic Feature Toggle") do
        expect(page).to have_css(".alert-success")
        expect(page).to have_content("Feature Enabled!")
        expect(page).to have_no_content("Feature Disabled")
      end

      # Clean up after test
      Flipper.disable(:demo_feature)
    end

    it "demonstrates testing user-specific features" do
      user = create(:user)
      sign_in user

      # Pattern 3: Enable feature for specific user
      Flipper.enable_actor(:premium_content, user)

      visit feature_flags_demo_path

      within(".card", text: "User-Specific Features") do
        expect(page).to have_css(".alert-info")
        expect(page).to have_content("Premium Content Available!")
      end

      # Test with different user
      other_user = create(:user)
      sign_in other_user

      visit feature_flags_demo_path

      within(".card", text: "User-Specific Features") do
        expect(page).to have_css(".alert-secondary")
        expect(page).to have_content("Premium content is not available")
      end

      # Clean up
      Flipper.disable(:premium_content)
    end

    it "demonstrates testing role-based features" do
      admin = create(:user, :admin)
      sign_in admin

      # Pattern 4: Enable feature for role group
      Flipper.enable_group(:admin_tools, :admins)

      visit feature_flags_demo_path

      within(".card", text: "Role-Based Features") do
        expect(page).to have_css(".alert-danger")
        expect(page).to have_content("Admin Tools")
      end

      # Test with non-admin user
      regular_user = create(:user)
      sign_in regular_user

      visit feature_flags_demo_path

      within(".card", text: "Role-Based Features") do
        expect(page).to have_no_content("Admin Tools")
      end

      # Clean up
      Flipper.disable(:admin_tools)
    end

    it "demonstrates testing percentage rollouts" do
      # Pattern 5: Testing percentage-based rollouts
      Flipper.enable_percentage_of_actors(:beta_ui, 50)

      # Create multiple users and check feature distribution
      enabled_count = 0
      10.times do
        user = create(:user)
        enabled_count += 1 if Flipper.enabled?(:beta_ui, user)
      end

      # Verify some users have it enabled (not all, not none)
      expect(enabled_count).to be > 0
      expect(enabled_count).to be < 10

      # Clean up
      Flipper.disable(:beta_ui)
    end

    it "demonstrates using shared contexts for feature flags" do
      # Pattern 6: Use shared contexts for common feature flag scenarios
      # Enable all demo features
      Flipper.enable(:demo_feature)
      Flipper.enable(:beta_ui)
      Flipper.enable(:premium_content)

      visit feature_flags_demo_path

      expect(page).to have_content("Feature Enabled!")
      expect(page).to have_content("New Beta UI")

      # Feature status should show enabled
      within(".card", text: "Feature Status Information") do
        expect(page).to have_css(".badge.bg-success", text: "Enabled", count: 2)
      end

      # Clean up
      Flipper.disable(:demo_feature)
      Flipper.disable(:beta_ui)
      Flipper.disable(:premium_content)
    end

    it "demonstrates testing feature flag combinations" do
      user = create(:user, :admin)
      sign_in user

      # Pattern 7: Test combinations of features
      Flipper.enable(:demo_feature)
      Flipper.enable_group(:admin_tools, :admins)
      Flipper.disable(:beta_ui)

      visit feature_flags_demo_path

      # Verify correct combination of features
      expect(page).to have_content("Feature Enabled!")
      expect(page).to have_content("Admin Tools")
      expect(page).to have_content("Standard UI")
      expect(page).to have_no_content("New Beta UI")

      # Clean up
      Flipper.disable(:demo_feature)
      Flipper.disable(:admin_tools)
    end
  end

  describe "Feature flag helper methods in tests" do
    it "can use helper methods directly in tests" do
      user = create(:user)

      # Test helper methods work correctly
      expect(Flipper.enabled?(:demo_feature, user)).to be false

      Flipper.enable_actor(:demo_feature, user)
      expect(Flipper.enabled?(:demo_feature, user)).to be true

      # Test feature is enabled for user
      expect(Flipper.enabled?(:demo_feature, user)).to be true

      # Clean up
      Flipper.disable(:demo_feature)
    end
  end
end
