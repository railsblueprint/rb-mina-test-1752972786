describe Settings::DestroyCommand, type: :command do

  let!(:admin) {create(:user,:superadmin)}
  let!(:setting) {create(:setting)}

  let(:subject) { described_class.call(id: setting.id, current_user: admin) }

  it "broadcasts ok" do
    expect{subject}.to broadcast(:ok)
  end

  it "destroys setting" do
    expect{subject}.to change{Setting.count}.by(-1)
    expect{setting.reload}.to raise_error(ActiveRecord::RecordNotFound)
  end

end