describe Users::CreateCommand, type: :command do

  let(:admin) {create(:user,:admin)}
  let(:params) { {first_name: "John", last_name: "Doe", email: "<EMAIL>"} }

  let(:subject) { described_class.call(params.merge(current_user: admin)) }

  it "broadcasts ok" do
    expect{subject}.to broadcast(:ok)
  end

  it "creates a new user" do
    expect{subject}.to change{User.count}.by(1)
  end
end