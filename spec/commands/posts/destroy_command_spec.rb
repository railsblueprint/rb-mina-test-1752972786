require "rails_helper"

describe Posts::DestroyCommand, type: :command do

  let!(:admin) {create(:user,:superadmin)}
  let!(:post) {create(:post)}

  let(:subject) { described_class.call(id: post.id, current_user: admin) }

  it "broadcasts ok" do
    expect{subject}.to broadcast(:ok)
  end

  it "destroys post" do
    expect{subject}.to change{Post.count}.by(-1)
    expect{post.reload}.to raise_error(ActiveRecord::RecordNotFound)
  end

end