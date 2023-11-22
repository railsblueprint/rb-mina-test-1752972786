require "rails_helper"

describe ChangePasswordCommand, type: :command do
  let(:admin) {create(:user,:admin)}
  let(:user) {create(:user, password: "12345678")}
  let(:params) { {password: "456", password_confirmation: "456", current_password: "12345678"} }

  let(:subject) { described_class.new(params.merge(user: user)) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:password_confirmation) }
  it { should validate_presence_of(:current_password) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  context "when current password is not valid" do
    let(:params) { {password: "456", password_confirmation: "456", current_password: "8765432321"} }

    it "broadcasts invalid" do
      expect{subject.call}.to broadcast(:invalid)
    end
  end

end