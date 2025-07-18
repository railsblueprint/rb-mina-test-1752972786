require "rails_helper"

RSpec.describe "OAuth Login" do
  before do
    driven_by(:rack_test)
  end

  describe "login page" do
    it "displays social login buttons" do
      visit new_user_session_path

      expect(page).to have_content("Or sign in with")
      expect(page).to have_button("Google")
      expect(page).to have_button("GitHub")
      expect(page).to have_button("Facebook")
    end
  end

  describe "registration page" do
    it "displays social login buttons" do
      visit new_user_registration_path

      expect(page).to have_content("Or sign in with")
      expect(page).to have_button("Google")
      expect(page).to have_button("GitHub")
      expect(page).to have_button("Facebook")
    end
  end

  describe "OAuth login flow" do
    before do
      mock_auth_hash(:google_oauth2, email: "oauth@example.com", name: "OAuth User")
    end

    it "creates a new user account via OAuth" do
      visit new_user_session_path

      expect {
        click_button "Google"
      }.to change(User, :count).by(1)

      expect(page).to have_current_path(root_path)
      user = User.last
      expect(user.email).to eq("oauth@example.com")
      expect(user.linked_providers).to include("google_oauth2")
    end

    it "signs in existing user with OAuth" do
      existing_user = create(:user, email: "oauth@example.com")
      visit new_user_session_path

      expect {
        click_button "Google"
      }.not_to change(User, :count)

      expect(page).to have_current_path(root_path)
      expect(existing_user.reload.linked_providers).to include("google_oauth2")
    end

    # This test is better suited as a request spec since we're testing backend OAuth logic
    # Moving to request specs where we can properly test the multi-provider functionality
  end

  describe "OAuth failure" do
    before do
      mock_invalid_auth_hash(:google_oauth2)
    end

    it "shows error message on authentication failure" do
      visit new_user_session_path
      click_button "Google"

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("Could not authenticate you")
    end
  end
end
