require "rails_helper"

RSpec.describe User do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  it { is_expected.to have_db_column(:email).of_type(:string) }

  describe "associations" do
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:user_identities).dependent(:destroy) }
  end

  describe "methods" do
    let(:user) { create(:user, first_name: "Foo", last_name: "Bar") }
    let(:russian) { create(:user, first_name: "Вася", last_name: "Пупкин") }
    let(:complex_name) { create(:user, first_name: "Foo Long", last_name: "Bar") }
    let(:anonymous) { create(:user, first_name: "", last_name: "") }

    let(:admin) { create(:user, :admin) }
    let(:superadmin) { create(:user, :superadmin) }

    describe "#full_name" do
      it "concatenates first_name and last_name" do
        expect(user.full_name).to eq("Foo Bar")
      end

      it "returns email when both names are blank" do
        expect(anonymous.full_name).to eq(anonymous.email)
      end
    end

    describe "#short_name" do
      it "concatenates first_name initial and last_name" do
        expect(user.short_name).to eq("F. Bar")
      end

      it "returns email when both names are blank" do
        expect(anonymous.short_name).to eq(anonymous.email)
      end
    end

    describe "#initials" do
      it "returns 2 first letters of names" do
        expect(user.initials).to eq("FB")
      end

      it "returns initials of 2 first words when first_name has spaces" do
        expect(complex_name.initials).to eq("FL")
      end

      it "works for non-latin letters" do
        expect(russian.initials).to eq("ВП")
      end

      it "returns 2 symbols of email" do
        expect(anonymous.initials).to eq(anonymous.email[0..1])
      end
    end

    describe "#avatar_color" do
      it "returns 4 when initials are FB" do
        expect(user.avatar_color).to eq(4)
      end
    end

    describe "#has_role" do
      it "returns true when user has role" do
        expect(admin).to have_role(:admin)
      end

      it "returns false when user don't have role" do
        expect(admin).not_to have_role(:other_role)
      end

      it "returns true for any role when user has superadmin role" do
        expect(superadmin).to have_role(:other_role)
      end
    end
  end

  describe "OAuth methods" do
    describe ".from_omniauth" do
      let(:auth_hash) {
        OmniAuth::AuthHash.new({
          provider:    "google_oauth2",
          uid:         "123456",
          info:        {
            email:      "oauth@example.com",
            name:       "OAuth User",
            first_name: "OAuth",
            last_name:  "User"
          },
          credentials: {
            token:         "mock_token",
            refresh_token: "mock_refresh_token",
            expires_at:    1.week.from_now.to_i
          }
        })
      }

      context "when no user exists" do
        it "creates a new user" do
          expect {
            described_class.from_omniauth(auth_hash)
          }.to change(described_class, :count).by(1)
        end

        it "creates a user identity" do
          expect {
            described_class.from_omniauth(auth_hash)
          }.to change(UserIdentity, :count).by(1)
        end

        it "sets user attributes from auth hash" do
          user = described_class.from_omniauth(auth_hash)
          expect(user.email).to eq("oauth@example.com")
          expect(user.first_name).to eq("OAuth")
          expect(user.last_name).to eq("User")
        end

        it "skips email confirmation" do
          user = described_class.from_omniauth(auth_hash)
          expect(user).to be_confirmed
        end
      end

      context "when user exists with same email" do
        let!(:existing_user) { create(:user, email: "oauth@example.com") }

        it "doesn't create a new user" do
          expect {
            described_class.from_omniauth(auth_hash)
          }.not_to change(described_class, :count)
        end

        it "creates a new identity for the existing user" do
          expect {
            described_class.from_omniauth(auth_hash)
          }.to change(existing_user.user_identities, :count).by(1)
        end

        it "returns the existing user" do
          user = described_class.from_omniauth(auth_hash)
          expect(user).to eq(existing_user)
        end
      end

      context "when identity already exists" do
        let!(:user) { create(:user) }
        let!(:identity) { create(:user_identity, user: user, provider: "google_oauth2", uid: "123456") }

        it "returns the existing user" do
          result = described_class.from_omniauth(auth_hash)
          expect(result).to eq(user)
        end

        it "doesn't create new records" do
          expect {
            described_class.from_omniauth(auth_hash)
          }.not_to change(described_class, :count)

          expect {
            described_class.from_omniauth(auth_hash)
          }.not_to change(UserIdentity, :count)
        end

        it "updates the OAuth tokens" do
          described_class.from_omniauth(auth_hash)
          identity.reload
          expect(identity.oauth_token).to start_with("mock_token_")
          expect(identity.oauth_refresh_token).to start_with("mock_refresh_token_")
        end
      end
    end

    describe ".new_with_session" do
      let(:params) { { email: "form@example.com" } }
      let(:session) { {} }

      context "with OAuth data in session" do
        let(:session) {
          {
            "devise.provider_data" => {
              "email"    => "session@example.com",
              "provider" => "github",
              "uid"      => "789"
            }
          }
        }

        it "uses email from session if params email is blank" do
          user = described_class.new_with_session({}, session)
          expect(user.email).to eq("session@example.com")
        end

        it "prefers params email over session email" do
          user = described_class.new_with_session(params, session)
          expect(user.email).to eq("form@example.com")
        end
      end
    end

    describe "#linked_providers" do
      let(:user) { create(:user) }

      it "returns empty array when no identities" do
        expect(user.linked_providers).to eq([])
      end

      it "returns array of provider names" do
        create(:user_identity, :google, user: user)
        create(:user_identity, :github, user: user)

        expect(user.linked_providers).to contain_exactly("google_oauth2", "github")
      end
    end

    describe "#linked_to?" do
      let(:user) { create(:user) }

      it "returns false when not linked" do
        expect(user.linked_to?(:google_oauth2)).to be false
      end

      it "returns true when linked" do
        create(:user_identity, :google, user: user)
        expect(user.linked_to?(:google_oauth2)).to be true
      end

      it "accepts string or symbol" do
        create(:user_identity, :github, user: user)
        expect(user.linked_to?("github")).to be true
        expect(user.linked_to?(:github)).to be true
      end
    end
  end

  describe ".update_social_profile_from_oauth" do
    let(:user) { create(:user) }

    context "with GitHub auth" do
      let(:auth_hash) {
        OmniAuth::AuthHash.new({
          provider: "github",
          uid:      "123456",
          info:     {
            nickname: "johndoe",
            urls:     { "GitHub" => "https://github.com/johndoe" }
          }
        })
      }

      it "populates github_profile when blank" do
        expect(user.github_profile).to be_blank
        described_class.update_social_profile_from_oauth(user, auth_hash)
        expect(user.reload.github_profile).to eq("https://github.com/johndoe")
      end

      it "doesn't overwrite existing github_profile" do
        user.update(github_profile: "https://github.com/existing")
        described_class.update_social_profile_from_oauth(user, auth_hash)
        expect(user.reload.github_profile).to eq("https://github.com/existing")
      end

      it "constructs URL from nickname if urls not provided" do
        auth_hash.info.urls = nil
        described_class.update_social_profile_from_oauth(user, auth_hash)
        expect(user.reload.github_profile).to eq("https://github.com/johndoe")
      end
    end

    context "with Facebook auth" do
      let(:auth_hash) {
        OmniAuth::AuthHash.new({
          provider: "facebook",
          uid:      "123456789",
          info:     {
            urls: { "Facebook" => "https://facebook.com/johndoe" }
          }
        })
      }

      it "populates facebook_profile when blank" do
        expect(user.facebook_profile).to be_blank
        described_class.update_social_profile_from_oauth(user, auth_hash)
        expect(user.reload.facebook_profile).to eq("https://facebook.com/johndoe")
      end

      it "uses UID as fallback" do
        auth_hash.info.urls = nil
        described_class.update_social_profile_from_oauth(user, auth_hash)
        expect(user.reload.facebook_profile).to eq("https://facebook.com/123456789")
      end
    end
  end
end
