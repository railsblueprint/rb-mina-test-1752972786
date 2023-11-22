require "rails_helper"

describe ContactUsCommand, type: :command do
  let(:params) { {name: "456", email: "abcd@dot.com", subject: "help", message: "me please"} }

  let(:subject) { described_class.new(params) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:message) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  it "sends email" do
    expect(TemplateMailer).to receive(:email).with(:contact_form_message, anything).and_call_original
    subject.call
  end
end