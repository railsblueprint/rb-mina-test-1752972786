require "rails_helper"

describe Settings::UpdateCommand, type: :command do

  let(:admin) {create(:user,:superadmin)}
  let(:user) {create(:user)}
  let(:setting) {create(:setting)}
  let(:params) { {alias: "zzzz", type: "string", value: "value", description: "description"} }

  let(:subject) { described_class.new(params.merge(id: setting.id, current_user: admin)) }

  it { should validate_presence_of(:alias) }
  it { should validate_presence_of(:type) }
  it { should validate_presence_of(:description) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  it "updates setting attributes", aggregate_failures: true do
    subject.call
    setting.reload

    expect(setting.alias).to eq("zzzz")
    expect(setting.type).to eq("string")
    expect(setting.value).to eq("value")
    expect(setting.description).to eq("description")
  end
end