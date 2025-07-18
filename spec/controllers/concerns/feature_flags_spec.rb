require "rails_helper"

RSpec.describe FeatureFlags do
  controller(ApplicationController) do
    include FeatureFlags # rubocop:disable RSpec/DescribedClass

    def test_feature
      if feature_enabled_for_current_user?(:test_feature)
        render plain: "feature enabled"
      else
        render plain: "feature disabled"
      end
    end

    def test_require_feature
      return unless require_feature!(:required_feature)

      render plain: "feature allowed"
    end
  end

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before do
    routes.draw do
      get "test_feature" => "anonymous#test_feature"
      get "test_require_feature" => "anonymous#test_require_feature"
    end
  end

  describe "#feature_enabled_for_current_user?" do
    context "when feature is globally enabled" do
      before { Flipper.enable(:test_feature) }
      after { Flipper.disable(:test_feature) }

      it "returns true" do
        sign_in user
        get :test_feature
        expect(response.body).to eq("feature enabled")
      end
    end

    context "when feature is disabled" do
      before { Flipper.disable(:test_feature) }

      it "returns false" do
        sign_in user
        get :test_feature
        expect(response.body).to eq("feature disabled")
      end
    end

    context "when feature is enabled for specific user" do
      before do
        Flipper.disable(:test_feature)
        Flipper.enable_actor(:test_feature, user)
      end

      after { Flipper.disable(:test_feature) }

      it "returns true for that user" do
        sign_in user
        get :test_feature
        expect(response.body).to eq("feature enabled")
      end

      it "returns false for other users" do
        other_user = create(:user)
        sign_in other_user
        get :test_feature
        expect(response.body).to eq("feature disabled")
      end
    end

    context "when feature is enabled for admin group" do
      before do
        Flipper.disable(:test_feature)
        Flipper.enable_group(:test_feature, :admins)
      end

      after { Flipper.disable(:test_feature) }

      it "returns true for admins" do
        sign_in admin
        get :test_feature
        expect(response.body).to eq("feature enabled")
      end

      it "returns false for non-admins" do
        sign_in user
        get :test_feature
        expect(response.body).to eq("feature disabled")
      end
    end
  end

  describe "#require_feature!" do
    context "when feature is enabled" do
      before do
        Flipper.enable(:required_feature)
        sign_in user
      end

      after { Flipper.disable(:required_feature) }

      it "allows access" do
        get :test_require_feature
        expect(response.body).to eq("feature allowed")
      end
    end

    context "when feature is disabled" do
      before do
        Flipper.disable(:required_feature)
        sign_in user
      end

      it "redirects to root path" do
        get :test_require_feature
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
