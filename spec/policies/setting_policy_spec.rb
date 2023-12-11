RSpec.describe SettingPolicy do
  let(:klass) { Setting }
  let(:object) { build(:setting) }
  subject { described_class }

  [:guest, :basic, :moderator, :admin].each do |role|
    context "for guest user" do
      let(:user) { role == :guest ? nil : create(:user, role) }

      permissions :index?, :new?, :create? do
        it { is_expected.to_not permit(user, klass) }
      end

      permissions :show?, :edit?, :update?, :destroy? do
        it { is_expected.to_not permit(user, object) }
      end
    end
  end

  context "for superadmin user" do
    let(:user) { build(:user, :superadmin) }

    context "non-dev environment" do
      permissions :index?  do
        it { is_expected.to permit(user, klass) }
      end

      permissions :new?, :create?  do
        it { is_expected.to_not permit(user, klass) }
      end

      permissions :mass_update?  do
        it { is_expected.to permit(user, klass) }
      end

      permissions :show? do
        it { is_expected.to permit(user, object) }
      end

      permissions :edit?, :create?, :update?, :destroy?  do
        it { is_expected.to_not permit(user, object) }
      end
    end

    context "dev environment" do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      permissions :index?, :new?, :create?  do
        it { is_expected.to permit(user, klass) }
      end

      permissions :show?, :edit?, :create?, :update?, :destroy?  do
        it { is_expected.to permit(user, object) }
      end
    end
  end
end
