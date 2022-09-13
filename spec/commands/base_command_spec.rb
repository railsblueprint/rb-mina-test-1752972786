require 'rails_helper'

RSpec.describe BaseCommand do

  let(:command_class) do
    Class.new(BaseCommand) do
      def process; end
    end
  end

  context "class methods" do
    subject { command_class }

    context ".call" do
      it "instanciates the command and invokes call" do
        expect_any_instance_of(subject).to receive(:call)
        subject.call
      end
    end
  end

  context "instance methods" do
    subject { command_class.new }

    context "#call" do
      context "when valid" do
        before do
          allow(subject).to receive(:valid?).and_return(true)
        end

        it "calls broadcast_ok" do
          expect(subject).to receive(:broadcast_ok)
          subject.call
        end
      end

      context "when failed" do
        before do
          allow(subject).to receive(:valid?).and_return(false)
        end

        it "calls broadcast_invalid" do
          expect(subject).to receive(:broadcast_invalid)
          subject.call
        end
      end
    end

    context "#broadcast_ok" do
      it "broadcasts :ok" do
        expect { subject.broadcast_ok }.to broadcast(:ok)
      end
    end

    context "#broadcast_invalid" do
      it "broadcasts :invalid with errors" do
        expect { subject.broadcast_invalid }.to broadcast(:invalid, subject.errors)
      end
    end

  end

end
