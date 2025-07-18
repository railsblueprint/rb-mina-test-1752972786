require "rails_helper"

RSpec.describe UserIdentity do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }

    context "uniqueness validations" do
      let(:user) { create(:user) }
      let!(:identity) { create(:user_identity, user: user, provider: "google_oauth2", uid: "123") }

      it "validates uniqueness of provider scoped to user" do
        duplicate_identity = build(:user_identity, user: user, provider: "google_oauth2", uid: "456")
        expect(duplicate_identity).not_to be_valid
        expect(duplicate_identity.errors[:provider]).to include("has already been taken")
      end

      it "validates uniqueness of uid scoped to provider" do
        other_user = create(:user)
        duplicate_identity = build(:user_identity, user: other_user, provider: "google_oauth2", uid: "123")
        expect(duplicate_identity).not_to be_valid
        expect(duplicate_identity.errors[:uid]).to include("has already been taken")
      end

      it "allows same uid for different providers" do
        github_identity = build(:user_identity, user: user, provider: "github", uid: "123")
        expect(github_identity).to be_valid
      end
    end
  end

  describe "#oauth_expires?" do
    let(:identity) { build(:user_identity) }

    context "when oauth_expires_at is nil" do
      before { identity.oauth_expires_at = nil }

      it "returns false" do
        expect(identity.oauth_expires?).to be false
      end
    end

    context "when oauth_expires_at is in the future" do
      before { identity.oauth_expires_at = 1.hour.from_now }

      it "returns false" do
        expect(identity.oauth_expires?).to be false
      end
    end

    context "when oauth_expires_at is in the past" do
      before { identity.oauth_expires_at = 1.hour.ago }

      it "returns true" do
        expect(identity.oauth_expires?).to be true
      end
    end
  end
end
