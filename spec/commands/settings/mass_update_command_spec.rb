describe Settings::MassUpdateCommand, type: :command do

  let(:admin) {create(:user,:superadmin)}
  let(:setting1) {create(:setting)}
  let(:setting2) {create(:setting)}
  let(:setting3) {create(:setting)}

  let(:params) { {
    setting1.id => {value: "value1"},
    setting2.id => {value: "value2"},
    setting3.id => {value: "value3"},
  } }

  let(:subject) { described_class.new(settings: params, current_user: admin) }

  context "with invalid params" do
    let(:params) { {
      "123" => {value: "value1"},
    }}

    it "broadcasts invalid" do
      expect{subject.call}.to broadcast :invalid, errors_exactly(
        base: :invalid_id
      )
    end
  end

  context "with valid params" do
    it "broadcasts ok" do
      expect{subject.call}.to broadcast(:ok)
    end

    it "updates setting attributes", aggregate_failures: true do
      subject.call
      expect(setting1.reload.value).to eq("value1")
      expect(setting2.reload.value).to eq("value2")
      expect(setting3.reload.value).to eq("value3")
    end
  end

  context "when not enough premissions" do
    let(:admin) {create(:user)}

    it "broadcasts unauthorized" do
      expect{subject.call}.to broadcast(:unauthorized)
    end
  end


end