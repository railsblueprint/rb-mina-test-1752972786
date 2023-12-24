describe Users::DestroyCommand, type: :command do
  let!(:admin) { create(:user, :superadmin) }
  let!(:user) { create(:user) }

  let(:subject) { described_class.call(id: user.id, current_user: admin) }

  it "broadcasts ok" do
    expect { subject }.to broadcast(:ok)
  end

  it "destroys user" do
    expect { subject }.to change { User.count }.by(-1)
    expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
