RSpec.describe ApplicationPolicy do
  let(:object) { double("test object", all: "all_objects", class: double(all: "all_objects")) }
  subject { described_class }

  context "for guest user" do
    let(:user) { nil }

    permissions :index?, :show? do
      it { is_expected.to permit(user, object) }
    end

    permissions :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.to_not permit(user, object) }
    end
  end

  context "for basic user" do
    let(:user) { build(:user) }

    permissions :index?, :show? do
      it { is_expected.to permit(user, object) }
    end

    permissions :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.to_not permit(user, object) }
    end
  end

  context "for moderator user" do
    let(:user) { build(:user, :moderator) }

    permissions :index?, :show? do
      it { is_expected.to permit(user, object) }
    end

    permissions :edit?, :create?, :update?, :destroy?, :unknown? do
      it { is_expected.to_not permit(user, object) }
    end
  end

  context "for admin user" do
    let(:user) { build(:user, :admin) }

    permissions :index?, :show?, :edit?, :create?, :update?, :destroy?, :unknown?  do
      it { is_expected.to permit(user, object) }
    end
  end

  context "for superadmin user" do
    let(:user) { build(:user, :admin) }

    permissions :index?, :show?, :edit?, :create?, :update?, :destroy?, :unknown?  do
      it { is_expected.to permit(user, object) }
    end
  end

  describe "#respond_to_missing?" do
    let(:user) { build(:user, :admin) }
    subject { described_class.new(user, object) }

    it "should respond to all methods" do
      expect(subject).to respond_to(:junk?)
    end
  end

  describe "#scope" do
    let(:user) { build(:user, :admin) }
    subject { described_class.new(user, object) }

    before do
      stub_const("RSpec::Mocks::DoublePolicy", Class.new(ApplicationPolicy))
    end

    it "should respond to all methods" do
      expect(subject.scope).to eq("all_objects")
    end
  end

  describe "Scope" do
    let(:user) { build(:user, :admin) }
    let(:scope) { described_class::Scope.new(user, object) }

    it "returns all objects" do
      expect(scope.resolve).to eq("all_objects")
    end
  end
end
