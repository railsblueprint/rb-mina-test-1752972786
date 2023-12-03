describe Posts::UpdateCommand, type: :command do

  let(:admin) {create(:user,:superadmin)}
  let(:user) {create(:user)}
  let(:post) {create(:post)}
  let(:params) { {title: "Title", body: "Text", user_id: user.id} }

  let(:subject) { described_class.new(params.merge(id: post.id, current_user: admin)) }

  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  it "updates user attributes", aggregate_failures: true do
    subject.call
    post.reload

    expect(post.title).to eq("Title")
    expect(post.body.to_s).to eq("<div class=\"trix-content\">\n  Text\n</div>\n")
    expect(post.user).to eq(user)
  end
end