describe Users::UpdateCommand, type: :command do

  let(:admin) {create(:user,:superadmin)}
  let(:user) {create(:user)}
  let(:params) { {first_name: "John", last_name: "Doe", email: "abcd@dot.com"} }

  let(:subject) { described_class.call(params.merge(id: user.id, current_user: admin)) }

  before do
    allow(TemplateDeviseMailer).to receive(:confirmation_instructions).and_return(double(deliver: true))
  end

  it "broadcasts ok" do
    expect{subject}.to broadcast(:ok)
  end

  it "updates user attributes", aggregate_failures: true do
    subject
    user.reload

    expect(user.first_name).to eq("John")
    expect(user.last_name).to eq("Doe")
  end

  it "stores new email to unconfirmed_email", aggregate_failures: true do
    subject
    user.reload

    expect(user.unconfirmed_email).to eq("abcd@dot.com")
  end
end