describe Posts::CreateCommand, type: :command do

  let(:admin) {create(:user,:admin)}
  let(:user) {create(:user)}
  let(:params) { {title: "Title", body: "Text", user_id: user.id} }

  let(:subject) { described_class.new(params.merge(current_user: admin)) }

  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  it "creates a new post" do
    expect{subject.call}.to change{Post.count}.by(1)
  end
end