require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:object) { double("test object") }
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
end
