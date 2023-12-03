describe BaseCommand do
  class BadCommand < BaseCommand
  end

  class SampleCommand < BaseCommand
    def process; end
  end

  class WithArgumentsCommand < BaseCommand
    attribute :a, Types::String
    validates :a, presence: true
    def process; end
  end

  class WithArgumentsStrictCommand < BaseCommand
    strict_attributes!
    attribute :a, Types::String
    validates :a, presence: true
    def process; end
  end

  class SubclassStrictCommand < WithArgumentsStrictCommand
    def process; end
  end

  class NonTransactionalCommand < BaseCommand
    skip_transaction!

    def process; end
  end

  let(:command_class) do
    SampleCommand
  end

  let(:command_with_arguments_class) do
    WithArgumentsCommand
  end

  let(:command_with_arguments_strict_class) do
    WithArgumentsStrictCommand
  end

  let(:command_subclass_strict_class) do
    SubclassStrictCommand
  end

  let(:non_transactional_class) do
    NonTransactionalCommand
  end

  let(:class_with_abort) do
    class AbortedCommand < BaseCommand
      skip_transaction!

      def process
        abort_command
        second_step
      end

      def second_step; end
    end
    AbortedCommand
  end

  context "class methods" do
    subject { command_class }

    context "when process is not defined" do
      it "raises exception" do
        expect { BadCommand.call }.to raise_error("Interface not implemented")
      end
    end

    context "when requested to run now" do
      it "instanciates the command and invokes call" do
        expect_any_instance_of(subject).to receive(:call)
        subject.call
      end
    end

    context "when called with ActionController::Parameters" do
      let(:command_class) { WithArgumentsCommand }
      let(:expected_params) {
        {
          a: "abc",
          user_id: "123"
        }
      }
      let(:additional_params) {
        {
          user_id: "123"
        }
      }
      let(:params) {
        ActionController::Parameters.new({
                                           with_arguments_command: {
                                             a: "abc",
                                             other: "def"
                                           },
                                           ignored_params: {
                                             key: "123"
                                           }
                                         })
      }
      it "permits correct parameters" do
        expect(subject).to receive(:call).with(expected_params)
        subject.call_for params, additional_params
      end
    end

    context "when requested to run in background" do
      it "instanciates the command and checks preflight conditions" do
        expect_any_instance_of(subject).to receive(:preflight_nok?)
        subject.call_later
      end

      context "when preflight checks are ok" do
        it "creates background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(false)
          allow(DelayedCommandJob).to receive(:perform_later)
          subject.call_later
          expect(DelayedCommandJob).to have_received(:perform_later)
        end
      end

      context "when preflight checks are not ok" do
        it "does not create background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(true)
          allow(DelayedCommandJob).to receive(:perform_later)
          subject.call_later
          expect(DelayedCommandJob).to_not have_received(:perform_later)
        end
      end
    end

    context "when invoked  with delay" do
      let (:delay) { { wait: 5.minutes } }

      it "instanciates the command and checks preflight conditions" do
        expect_any_instance_of(subject).to receive(:preflight_nok?)
        subject.call_at(delay)
      end

      context "when preflight checks are ok" do
        it "creates background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(false)
          allow(DelayedCommandJob).to receive(:set).and_call_original
          subject.call_at(delay)
          expect(DelayedCommandJob).to have_received(:set)
        end
      end

      context "when preflight checks are not ok" do
        it "does not create background job" do
          expect_any_instance_of(subject).to receive(:preflight_nok?).and_return(true)
          allow(DelayedCommandJob).to receive(:set).and_call_original
          subject.call_at(delay)
          expect(DelayedCommandJob).to_not have_received(:set)
        end
      end
    end
  end

  context "instance methods" do
    subject { command_class.new }

    it "returns false as persisited? by default" do
      expect(subject.persisted?).to eq(false)
    end

    context "when subclass of this command is #call'ed" do
      context "with valid parameters" do
        before do
          allow(subject).to receive(:valid?).and_return(true)
        end

        it "calls broadcast_ok" do
          expect { subject.call }.to broadcast(:ok)
        end
      end

      context "with invalid parameters" do
        before do
          allow(subject).to receive(:valid?).and_return(false)
        end

        it "calls broadcast_invalid" do
          expect(subject).to receive(:broadcast_invalid)
          subject.call
        end
      end

      context "with missing parameters and loose mode" do
        subject { command_with_arguments_class.new }

        it "calls broadcast_invalid" do
          expect(subject).to receive(:broadcast_invalid)
          subject.call
        end

        it "does not raise exception" do
          expect { subject }.to_not raise_exception
        end
      end

      context "with missing parameters and strict mode" do
        subject { command_with_arguments_strict_class.new }

        it "raises exception" do
          expect { subject }.to raise_exception(Dry::Struct::Error)
        end
      end

      context "with missing parameters and subclass of command with strict mode" do
        subject { command_subclass_strict_class.new }

        it "raises exception" do
          expect { subject }.to raise_exception(Dry::Struct::Error)
        end
      end

      context "when command is transactional" do
        it "runs in transaction block" do
          allow(ActiveRecord::Base).to receive(:transaction).and_call_original
          subject.call
          expect(ActiveRecord::Base).to have_received(:transaction)
        end
      end

      context "when command is non-transactional" do
        subject { non_transactional_class.new }
        it "runs without transaction block" do
          allow(ActiveRecord::Base).to receive(:transaction).and_call_original
          subject.call
          expect(ActiveRecord::Base).to_not have_received(:transaction)
        end
      end
    end

    context "when command is aborted using #abort_command" do
      subject { class_with_abort.new }

      it "broadcasts :abort with errors" do
        expect { subject.call }.to broadcast(:abort, subject.errors)
      end

      it "prevents further execution" do
        allow(subject).to receive(:second_step).and_call_original
        subject.call
        expect(subject).to_not have_received(:second_step)
      end
    end
  end
end
