describe Pages::DestroyCommand, type: :command do

  let!(:admin) {create(:user,:superadmin)}
  let!(:page) {create(:page)}

  let(:subject) { described_class.call(id: page.id, current_user: admin) }

  it "broadcasts ok" do
    expect{subject}.to broadcast(:ok)
  end

  it "destroys post" do
    expect{subject}.to change{Page.count}.by(-1)
    expect{page.reload}.to raise_error(ActiveRecord::RecordNotFound)
  end

end