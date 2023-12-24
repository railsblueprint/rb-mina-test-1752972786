describe Pages::CreateCommand, type: :command do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:params) { { title: "Title", body: "Text", url: "zzz" } }

  let(:subject) { described_class.new(params.merge(current_user: admin)) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "creates a new page" do
    expect { subject.call }.to change { Page.count }.by(1)
  end
end
