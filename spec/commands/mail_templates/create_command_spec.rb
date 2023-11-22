require "rails_helper"

describe MailTemplates::CreateCommand, type: :command do
  let(:admin) {create(:user,:admin)}
  let(:user) {create(:user)}
  let(:params) { {alias: "new_temaplte", layout: "simple", body: "zzz"} }

  let(:subject) { described_class.new(params.merge(current_user: admin)) }

  it { should validate_presence_of(:alias) }
  it { should validate_presence_of(:layout) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  it "creates a new page" do
    expect{subject.call}.to change{MailTemplate.count}.by(1)
  end
end