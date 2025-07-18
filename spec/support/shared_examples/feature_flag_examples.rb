RSpec.shared_examples "feature flag controlled" do |feature_name, enabled_content, disabled_content|
  context "when #{feature_name} is enabled" do
    before { Flipper.enable(feature_name) }
    after { Flipper.disable(feature_name) }

    it "shows enabled content" do
      subject
      expect(response.body).to include(enabled_content) if enabled_content
      expect(response.body).not_to include(disabled_content) if disabled_content
    end
  end

  context "when #{feature_name} is disabled" do
    before { Flipper.disable(feature_name) }

    it "shows disabled content" do
      subject
      expect(response.body).not_to include(enabled_content) if enabled_content
      expect(response.body).to include(disabled_content) if disabled_content
    end
  end
end

RSpec.shared_examples "user feature flag controlled" do |feature_name, user_trait=nil|
  let(:user) { user_trait ? create(:user, user_trait) : create(:user) }

  context "when #{feature_name} is enabled for user" do
    before do
      sign_in user
      Flipper.enable_actor(feature_name, user)
    end

    after { Flipper.disable(feature_name) }

    it "allows access" do
      subject
      expect(response).to have_http_status(:success)
    end
  end

  context "when #{feature_name} is disabled for user" do
    before do
      sign_in user
      Flipper.disable(feature_name)
    end

    it "denies access" do
      subject
      expect(response).to redirect_to(root_path)
    end
  end
end

RSpec.shared_examples "role-based feature flag" do |feature_name, role_name|
  let(:user_with_role) { create(:user, role_name) }
  let(:user_without_role) { create(:user) }

  before { Flipper.enable_group(feature_name, role_name.to_s.pluralize) }
  after { Flipper.disable(feature_name) }

  context "when user has #{role_name} role" do
    before { sign_in user_with_role }

    it "shows feature" do
      subject
      expect(response).to have_http_status(:success)
    end
  end

  context "when user does not have #{role_name} role" do
    before { sign_in user_without_role }

    it "hides feature" do
      subject
      expect(response).to have_http_status(:success)
      # Add specific content checks based on your needs
    end
  end
end

# Helper methods for feature flag testing
module FeatureFlagTestHelpers
  def with_feature(feature_name, actor=nil)
    if actor
      Flipper.enable_actor(feature_name, actor)
    else
      Flipper.enable(feature_name)
    end

    yield
  ensure
    Flipper.disable(feature_name)
  end

  def without_feature(feature_name)
    Flipper.disable(feature_name)
    yield
  end

  def with_feature_for_percentage(feature_name, percentage)
    Flipper.enable_percentage_of_actors(feature_name, percentage)
    yield
  ensure
    Flipper.disable(feature_name)
  end

  def with_feature_for_group(feature_name, group_name)
    Flipper.enable_group(feature_name, group_name)
    yield
  ensure
    Flipper.disable(feature_name)
  end
end

RSpec.configure do |config|
  config.include FeatureFlagTestHelpers
end
