require 'spec_helper'

require 'atelier/command'

describe Atelier::Command do

  describe '#initialize' do
    subject { Atelier::Command.new(:cmd_name) }
    its(:name) { is_expected.to eq :cmd_name }

    context 'with options' do
      expected_options = {
        default:       :something_true,
        super_command: :expected_command,
        title:         :expected_title,
        description:   :expected_description,
        commands:      { expected_commands: true },
        action:        :expected_action
      }
      subject { Atelier::Command.new(:cmd_name, expected_options) }

      its(:default?) { is_expected.to eq true }

      [:super_command, :title, :description, :commands, :action].each do |option_name|
        its(option_name) { is_expected.to eq expected_options[option_name] }
      end
    end

    context 'with a block' do
      expected_block = Proc.new { :expected_block }

      it 'forwards the block to the load method' do
        allow_any_instance_of(Atelier::Command).to receive(:load) { |&block| expect(block).to eq expected_block }
        c = Atelier::Command.new(:cmd_name, { default: true }, &expected_block)
        expect(c).to have_received(:load).once
      end
    end
  end

  describe '#load' do
    subject { Atelier::Command.new(:cmd_name, { default: true } ) } # default options avoid to get several command instance created

    it 'gives the command to the block' do
      subject.load { |cmd_name| expect(cmd_name).to eq subject }
    end

    it 'is loading only when the block is executing' do
      expect(subject.loading?).to eq false
      subject.load { expect(subject.loading?).to eq true }
      expect(subject.loading?).to eq false
    end
  end

  describe '#parse_options!' do

    describe 'with declared options' do
      switch_name = '--first'
      option_name = :first

      before(:all) do
        @cmd = Atelier::Command.new(:cmd_name)
        @cmd.option(option_name, "#{switch_name} VALUE")
        @cmd
      end

      it 'forwards the message to option_parser' do
        params = ['arg1', 'arg2']
        expect(@cmd.option_parser).to receive(:parse).with(params)
        @cmd.send(:parse_options!, params)
      end

      context 'when parsing declared options' do
        expected_value = 'expected_value'

        subject { @cmd.send(:parse_options!, ['arg1', switch_name, expected_value, 'arg2']) }

        it { is_expected.to match_array ['arg1', 'arg2'] }

        describe 'its options' do
          subject { @cmd.options }

          it { is_expected.to be_a Hash }
          its([option_name]) { is_expected.to eq expected_value }
        end
      end

      context 'when parsing undeclared options' do
        subject { @cmd }

        it 'raises an InvalidOption error' do
          expect { subject.send(:parse_options!, ['arg1', '--undeclared', 'arg2']) }.to raise_error(OptionParser::InvalidOption)
        end
      end
    end

    describe 'without declared options' do
      expected_parameters = [:first_param, '--invalid-option']

      before(:all) { @cmd = Atelier::Command.new(:cmd_name) }
      subject { @cmd.send(:parse_options!, expected_parameters) }

      it 'does NOT raise InvalidOption' do
        expect(subject).to eq expected_parameters
      end
    end
  end

  describe '#parse_arguments' do
    before(:all) do
      argument_parser = Atelier::ArgumentParser.new
      argument_parser.param(:first_arg)
      @cmd = Atelier::Command.new(:cmd_name, argument_parser: argument_parser)
    end

    subject { @cmd }

    it 'forwards the message to argument_parser' do
      params = ['arg1', 'arg2']
      expect(@cmd.argument_parser).to receive(:parse).with(params)
      @cmd.send(:parse_arguments, params)
    end
  end

  describe '#run' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name)
      @cmd.action { |*params| params }
    end
    subject { @cmd }

    context 'with options' do
      it 'receives parse_options!' do
        params = ['arg1', 'arg2']
        expect(@cmd).to receive(:parse_options!).with(params)
        @cmd.run(*params)
      end
    end

    context 'with parameters' do
      parameter       = :param
      expected_result = [parameter]

      before(:all) do
        @cmd = Atelier::Command.new(:cmd_name)
        @cmd.action { |*args| args }
      end

      context 'if NO arguments parsing is configured' do
        subject { @cmd.run(parameter) }

        it { is_expected.to be_a Array }
        it { is_expected.to eq expected_result }
      end

      context 'if arguments parsing is configured' do
        before(:all) do
          argument_parser = Atelier::ArgumentParser.new
          argument_parser.param(:first_arg)
          @cmd = Atelier::Command.new(:cmd_name, argument_parser: argument_parser)
          @cmd.action { |args| args }
        end

        it 'receives parse_arguments' do
          params = ['arg1', 'arg2']
          expect(@cmd).to receive(:parse_arguments).with(params)
          @cmd.run(*params)
        end

        describe 'parsed arguments' do
          subject { @cmd.run(*[parameter, :ignored]) }

          its([:first_arg]) { is_expected.to eq parameter }
        end
      end

    end

    context 'with an existing sub-command' do
      before(:all) do
        @cmd = Atelier::Command.new(:cmd_name) do |c|
          c.command(:sub_cmd_name) { }
        end
      end

      subject { @cmd }

      it 'calls `run` on the sub-command' do
        expect(subject.commands[:sub_cmd_name]).to receive(:run).with(:action_name, :param)
        subject.run('sub_cmd_name', :action_name, :param)
      end
    end
  end

  describe '#action' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.action { :expected_result }
      end
    end
    subject { @cmd.action }

    it { is_expected.to be_a Proc }
  end

  describe '#commands' do
    before(:all) do
      @sub = nil
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.command(:sub_cmd_name) { |sub| @sub = sub }
      end
    end

    subject { @cmd.commands }

    its(:size) { is_expected.to eq 5 }

    describe 'its sub command' do
      subject { @cmd.commands[:sub_cmd_name] }

      it { is_expected.to be_a Atelier::Command }
      its(:name) { is_expected.to eq :sub_cmd_name }

      it 'its super_command is_expected.to equal the parent command' do
        expect(subject.super_command).to eq @cmd
      end
    end
  end

  describe 'default commands' do
    before(:all) { @cmd = Atelier::Command.new(:cmd_name) {} }
    subject      { @cmd.commands }

    it { is_expected.to include :help }
    it { is_expected.to include :commands }
    it { is_expected.to include :complete }
    it { is_expected.to include :completion }
  end


  describe '#available_switches' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |cmd_name|
        cmd_name.option(:alert, '-a', '--alert ALERT', 'Alert')
      end
    end
    subject { @cmd.available_switches }

    its(:size) { is_expected.to eq 1 }

    describe 'the defined switch' do
      subject { @cmd.available_switches.first }

      its(:short) { is_expected.to match_array ['-a'] }
      its(:long)  { is_expected.to match_array ['--alert'] }
    end
  end


  describe '#available_switche_names' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |cmd_name|
        cmd_name.option(:alert, '-a', '--alert ALERT', 'Alert')
      end
    end
    subject { @cmd.available_switche_names }

    it { is_expected.to match_array ['-a', '--alert'] }
  end

end
