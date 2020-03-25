require 'spec_helper'

require 'atelier/command'

describe Atelier::Command do
  subject { Atelier::Command.new(:cmd_name) }

  describe '#initialize' do
    its(:name) { is_expected.to eq :cmd_name }
    its(:super_command) { is_expected.to eq nil }
    its(:application) { is_expected.to eq nil }
    its(:default?) { is_expected.to eq false }

    its(:title) { is_expected.to eq nil }
    its(:description) { is_expected.to eq nil }
    its(:action) { is_expected.to eq nil }

    context 'with options' do
      subject {
        Atelier::Command.new(:cmd_name,
          application:   :application,
          super_command: :expected_command,
          default:       :something_true,
        )
      }

      its(:name) { is_expected.to eq :cmd_name }
      its(:super_command) { is_expected.to eq :expected_command }
      its(:application) { is_expected.to eq :application }
      its(:default?) { is_expected.to eq true }

      its(:title) { is_expected.to eq nil }
      its(:description) { is_expected.to eq nil }
      its(:action) { is_expected.to eq nil }
    end

    context 'with a block' do
      expected_block = Proc.new { :expected_block }

      it 'forwards the block to the load method' do
        allow_any_instance_of(Atelier::Command).to receive(:load) { |&block| expect(block).to eq expected_block }
        # default options avoid to get several command instance created
        # FIXME Will be useless when the default command has its proper class
        c = Atelier::Command.new(:cmd_name, default: true, &expected_block)
        expect(c).to have_received(:load).once
      end
    end
  end

  describe '#action' do
    expected_proc = Proc.new { :overriden }
    before { subject.action(&expected_proc) }

    its(:action) { is_expected.to eq expected_proc }
  end

  describe '#load' do
    it 'loads the command synchronously' do
      loaded = false
      subject.load { loaded = true }
      expect(loaded).to eq true
    end

    it 'inject the command as block parameter' do
      subject.load { |cmd| expect(cmd).to eq subject }
    end
  end

  describe '#run' do
    before { subject.action {} }

    context 'with options' do
      context "when options are NOT declared" do
        it "calls the action with the given options as raw parameters" do
          expect(subject.action).to receive(:call).with('--option1', 'OPTION VALUE')
          subject.run('--option1', 'OPTION VALUE')
        end
      end

      context "when options are declared" do
        before { subject.option(:declared_option, '--declared_option DECLARED_OPTION') }

        it "calls the action without giving the options through parameters" do
          expect(subject.action).to receive(:call).with(no_args)
          subject.run('--declared_option', 'OPTION VALUE')
        end

        it "provides the option through options" do
          expect(subject.action).to receive(:call) do
            expect(subject.options).to eq(declared_option: 'OPTION VALUE')
          end
          subject.run('--declared_option', 'OPTION VALUE')
        end

        context "with undeclared options" do
          it "raises an OptionParser::InvalidOption" do
            expect {
              subject.run('--undeclared_option', 'OPTION VALUE')
            }.to raise_error(OptionParser::InvalidOption)
          end
        end
      end
    end

    context 'with parameters' do
      context 'if NO arguments parsing is configured' do
        it "calls the action the raw parameters" do
          expect(subject.action).to receive(:call).with('param1', 'param2')
          subject.run('param1', 'param2')
        end
      end

      context 'if arguments parsing is configured' do
        before { subject.param(:first_param) }

        it "calls the action with the first_param parameters as a keyword arg" do
          expect(subject.action).to receive(:call).with(first_param: 'param1')
          subject.run('param1', 'ignored_param')
        end
      end
    end

    context 'with options and parameters' do
      context "when options and parameters are NOT declared" do
        it "calls the action with the given argv as raw parameters" do
          expect(subject.action).to receive(:call).with('param1', '--option1', 'OPTION VALUE', 'param2')
          subject.run('param1', '--option1', 'OPTION VALUE', 'param2')
        end
      end

      context "when options and parameters are declared" do
        before do
          subject.param(:first_param)
          subject.option(:declared_option, '--declared_option DECLARED_OPTION')
        end

        it "calls the action with the first_param parameters" do
          expect(subject.action).to receive(:call).with(first_param: 'param1')
          subject.run('--declared_option', 'DECLARED_OPTION', 'param1', 'ignored_param')
        end

        it "provides the option through options" do
          expect(subject.action).to receive(:call) do
            expect(subject.options).to eq(declared_option: 'DECLARED_OPTION')
          end
          subject.run('--declared_option', 'DECLARED_OPTION', 'param1', 'ignored_param')
        end
      end
    end

    context 'with an existing sub-command' do
      before { subject.command(:sub_cmd_name) {} }

      context "when the first argument match the sub-command name" do
        it 'calls `run` on the sub-command' do
          sub_command = subject.sub_commands_hash[:sub_cmd_name]
          expect(sub_command).to receive(:run).with('--option1', 'option1' 'param2')
          subject.run('sub_cmd_name', '--option1', 'option1' 'param2')
        end
      end

      context "when the another argument match the sub-command name" do
        it 'does NOT call `run` on the sub-command' do
          sub_command = subject.sub_commands_hash[:sub_cmd_name]
          expect(sub_command).to_not receive(:run)
          subject.run('param1', 'sub_cmd_name')
        end

        it 'calls command action' do
          expect(subject.action).to receive(:call)
          subject.run('param1', 'sub_cmd_name')
        end
      end
    end
  end

  describe 'default commands' do
    it { expect(subject.sub_command_names).to include :help }
    it { expect(subject.sub_command_names).to include :commands }
    it { expect(subject.sub_command_names).to include :complete }
    it { expect(subject.sub_command_names).to include :completion }
  end
end
