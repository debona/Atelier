require 'spec_helper'

require 'atelier/command'

describe Atelier::Command do

  describe '#initialize' do
    subject { Atelier::Command.new(:cmd_name) }
    its(:name) { should == :cmd_name }

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

      its(:default?) { should == true }

      [:super_command, :title, :description, :commands, :action].each do |option_name|
        its(option_name) { should == expected_options[option_name] }
      end
    end

    context 'with a block' do
      expected_block = Proc.new { :expected_block }

      it 'should forward the block to the load method' do
        Atelier::Command.any_instance.stub(:load) { |&block| block.should == expected_block }
        c = Atelier::Command.new(:cmd_name, { default: true }, &expected_block)
        c.should have_received(:load).once
      end
    end
  end

  describe '#load' do
    subject { Atelier::Command.new(:cmd_name, { default: true } ) } # default options avoid to get several command instance created

    it 'should give the command to the block' do
      subject.load { |cmd_name| cmd_name.should == subject }
    end

    it 'should be loading only when the block is executing' do
      subject.loading?.should be_false
      subject.load { subject.loading?.should be_true }
      subject.loading?.should be_false
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

      it 'should forward the message to option_parser' do
        params = ['arg1', 'arg2']
        @cmd.option_parser.should_receive(:parse).with(params)
        @cmd.send(:parse_options!, params)
      end

      context 'when parsing declared options' do
        expected_value = 'expected_value'

        subject { @cmd.send(:parse_options!, ['arg1', switch_name, expected_value, 'arg2']) }

        it { should match_array ['arg1', 'arg2'] }

        describe 'its options' do
          subject { @cmd.options }

          it { should be_a Hash }
          its([option_name]) { should == expected_value }
        end
      end

      context 'when parsing undeclared options' do
        subject { @cmd }

        it 'should raise ' do
          expect { subject.send(:parse_options!, ['arg1', '--undeclared', 'arg2']) }.to raise_error(OptionParser::InvalidOption)
        end
      end
    end

    describe 'without declared options' do
      expected_parameters = [:first_param, '--invalid-option']

      before(:all) { @cmd = Atelier::Command.new(:cmd_name) }
      subject { @cmd.send(:parse_options!, expected_parameters) }

      it 'should not raise InvalidOption' do
        subject.should == expected_parameters
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

    it 'should forward the message to argument_parser' do
      params = ['arg1', 'arg2']
      @cmd.argument_parser.should_receive(:parse).with(params)
      @cmd.send(:parse_arguments, params)
    end
  end

  describe '#arguments' do
    before(:all) do
      argument_parser = Atelier::ArgumentParser.new
      argument_parser.param(:first_arg, 'first_desc')
      argument_parser.params(:other_args, 'other_descs')
      @cmd = Atelier::Command.new(:cmd_name, argument_parser: argument_parser)
    end

    subject { @cmd }

    it 'should yield with arguments info' do
      expect { |b| subject.arguments(&b) }.to yield_successive_args(
        [:first_arg, false, 'first_desc'],
        [:other_args, true, 'other_descs']
      )
    end
  end

  describe '#run' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name)
      @cmd.action { |*params| params }
    end
    subject { @cmd }

    context 'with options' do
      it 'should receive parse_options!' do
        params = ['arg1', 'arg2']
        @cmd.stub(:parse_options!)
        @cmd.should_receive(:parse_options!).with(params)
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

        it { should be_a Array }
        it { should == expected_result }
      end

      context 'if arguments parsing is configured' do
        before(:all) do
          argument_parser = Atelier::ArgumentParser.new
          argument_parser.param(:first_arg)
          @cmd = Atelier::Command.new(:cmd_name, argument_parser: argument_parser)
          @cmd.action { |args| args }
        end

        it 'should receive parse_arguments' do
          params = ['arg1', 'arg2']
          @cmd.stub(:parse_arguments)
          @cmd.should_receive(:parse_arguments).with(params)
          @cmd.run(*params)
        end

        describe 'parsed arguments' do
          subject { @cmd.run(*[parameter, :ignored]) }

          its([:first_arg]) { should == parameter }
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

      it 'should call `run` on the sub-command' do
        subject.commands[:sub_cmd_name].should_receive(:run).with(:action_name, :param)
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

    it { should be_a Proc }
  end

  describe '#commands' do
    before(:all) do
      @sub = nil
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.command(:sub_cmd_name) { |sub| @sub = sub }
      end
    end

    subject { @cmd.commands }

    it { should have(5).item }

    describe 'its sub command' do
      subject { @cmd.commands[:sub_cmd_name] }

      it { should be_a Atelier::Command }
      its(:name) { should == :sub_cmd_name }

      it 'its super_command should equal the parent command' do
        subject.super_command.should == @cmd
      end
    end
  end

  describe 'default commands' do
    before(:all) { @cmd = Atelier::Command.new(:cmd_name) {} }
    subject      { @cmd.commands }

    it { should include :help }
    it { should include :commands }
    it { should include :complete }
    it { should include :completion }
  end


  describe '#available_switches' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |cmd_name|
        cmd_name.option(:alert, '-a', '--alert ALERT', 'Alert')
      end
    end
    subject { @cmd.available_switches }

    its(:size) { should == 1 }

    describe 'the defined switch' do
      subject { @cmd.available_switches.first }

      its(:short) { should match_array ['-a'] }
      its(:long)  { should match_array ['--alert'] }
    end
  end


  describe '#available_switche_names' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |cmd_name|
        cmd_name.option(:alert, '-a', '--alert ALERT', 'Alert')
      end
    end
    subject { @cmd.available_switche_names }

    it { should match_array ['-a', '--alert'] }
  end

end
