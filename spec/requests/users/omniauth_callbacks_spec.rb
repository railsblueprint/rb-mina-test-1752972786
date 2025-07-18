require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks" do
  describe "OAuth callbacks" do
    %w[google_oauth2 github facebook].each do |provider|
      context "#{provider} authentication" do
        before do
          Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
          Rails.application.env_config["omniauth.auth"] = mock_auth_hash(provider)
        end

        describe "POST /users/auth/#{provider}/callback" do
          context "when user doesn't exist" do
            it "creates a new user" do
              expect {
                post "/users/auth/#{provider}/callback"
              }.to change(User, :count).by(1)
            end

            it "creates a user identity" do
              expect {
                post "/users/auth/#{provider}/callback"
              }.to change(UserIdentity, :count).by(1)
            end

            it "signs in the user" do
              post "/users/auth/#{provider}/callback"
              expect(controller.current_user).to be_present
              expect(controller.current_user.email).to eq("user@example.com")
            end

            it "redirects to root path" do
              post "/users/auth/#{provider}/callback"
              expect(response).to redirect_to(root_path)
            end
          end

          context "when user exists with same email" do
            let!(:existing_user) { create(:user, email: "user@example.com") }

            it "doesn't create a new user" do
              expect {
                post "/users/auth/#{provider}/callback"
              }.not_to change(User, :count)
            end

            it "creates a user identity for the existing user" do
              expect {
                post "/users/auth/#{provider}/callback"
              }.to change(existing_user.user_identities, :count).by(1)
            end

            it "signs in the existing user" do
              post "/users/auth/#{provider}/callback"
              expect(controller.current_user).to eq(existing_user)
            end
          end

          context "when user already has identity for this provider" do
            let!(:user) { create(:user, email: "user@example.com") }
            let!(:identity) { create(:user_identity, user: user, provider: provider, uid: "123456") }

            it "doesn't create a new user or identity" do
              expect {
                post "/users/auth/#{provider}/callback"
              }.not_to change(User, :count)

              expect {
                post "/users/auth/#{provider}/callback"
              }.not_to change(UserIdentity, :count)
            end

            it "updates the OAuth tokens" do
              post "/users/auth/#{provider}/callback"
              identity.reload
              expect(identity.oauth_token).to start_with("mock_token_")
            end

            it "signs in the user" do
              post "/users/auth/#{provider}/callback"
              expect(controller.current_user).to eq(user)
            end
          end

          context "when authentication fails" do
            before do
              mock_invalid_auth_hash(provider.to_sym)
            end

            it "handles authentication errors gracefully" do
              get "/users/auth/#{provider}/callback", params: { error: "access_denied" }
              expect(response).to redirect_to(new_user_session_path) # OmniAuth redirects to login on errors
            end
          end
        end
      end
    end

    describe "multi-provider support" do
      let(:email) { "multi@example.com" }

      it "links multiple providers to the same user account" do
        # First login with Google
        Rails.application.env_config["omniauth.auth"] = mock_auth_hash(:google_oauth2, email: email)
        post "/users/auth/google_oauth2/callback"
        google_user = User.find_by(email: email)

        # Then login with GitHub
        Rails.application.env_config["omniauth.auth"] = mock_auth_hash(:github, email: email)
        post "/users/auth/github/callback"
        github_user = User.find_by(email: email)

        # Should be the same user
        expect(github_user).to eq(google_user)
        expect(github_user.user_identities.count).to eq(2)
        expect(github_user.linked_providers).to contain_exactly("google_oauth2", "github")
      end
    end
  end
end
