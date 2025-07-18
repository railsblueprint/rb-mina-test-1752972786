require "rails_helper"

RSpec.describe FeatureFlagsHelper do
  let(:user) { create(:user) }

  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe "#feature_enabled?" do
    context "when feature is enabled" do
      before { Flipper.enable(:test_feature) }
      after { Flipper.disable(:test_feature) }

      it "returns true" do
        expect(helper.feature_enabled?(:test_feature)).to be true
      end
    end

    context "when feature is disabled" do
      before { Flipper.disable(:test_feature) }

      it "returns false" do
        expect(helper.feature_enabled?(:test_feature)).to be false
      end
    end
  end

  describe "#with_feature" do
    context "when feature is enabled" do
      before { Flipper.enable(:test_feature) }
      after { Flipper.disable(:test_feature) }

      it "renders the block content" do
        result = helper.with_feature(:test_feature) { "Feature content" }
        expect(result).to eq("Feature content")
      end
    end

    context "when feature is disabled" do
      before { Flipper.disable(:test_feature) }

      it "returns nil" do
        result = helper.with_feature(:test_feature) { "Feature content" }
        expect(result).to be_nil
      end
    end
  end

  describe "#without_feature" do
    context "when feature is enabled" do
      before { Flipper.enable(:test_feature) }
      after { Flipper.disable(:test_feature) }

      it "returns nil" do
        result = helper.without_feature(:test_feature) { "Fallback content" }
        expect(result).to be_nil
      end
    end

    context "when feature is disabled" do
      before { Flipper.disable(:test_feature) }

      it "renders the block content" do
        result = helper.without_feature(:test_feature) { "Fallback content" }
        expect(result).to eq("Fallback content")
      end
    end
  end

  describe "#feature_percentage" do
    context "when percentage is set" do
      before do
        Flipper.enable_percentage_of_actors(:test_feature, 25)
      end

      after { Flipper.disable(:test_feature) }

      it "returns the percentage value" do
        expect(helper.feature_percentage(:test_feature)).to eq(25)
      end
    end

    context "when percentage is not set" do
      before { Flipper.disable(:test_feature) }

      it "returns 0" do
        expect(helper.feature_percentage(:test_feature)).to eq(0)
      end
    end
  end

  describe "#feature_groups" do
    context "when groups are enabled" do
      before do
        Flipper.enable_group(:test_feature, :admins)
        Flipper.enable_group(:test_feature, :beta_testers)
      end

      after { Flipper.disable(:test_feature) }

      it "returns the enabled groups" do
        groups = helper.feature_groups(:test_feature)
        expect(groups).to include("admins", "beta_testers")
      end
    end

    context "when no groups are enabled" do
      before { Flipper.disable(:test_feature) }

      it "returns empty array" do
        expect(helper.feature_groups(:test_feature)).to eq([])
      end
    end
  end
end
