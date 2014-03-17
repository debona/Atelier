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

  describe '#run' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.action { |*params| params }
      end
    end
    subject { @cmd }

    context 'with parameters' do

      parameter       = :param
      expected_result = [parameter]
      subject { @cmd.run(parameter) }

      it { should be_a Array }
      it { should == expected_result }

      context 'if arguments parsing is configured' do
        before(:all) do
          argument_parser = Atelier::ArgumentParser.new
          argument_parser.param(:first_arg)
          @cmd = Atelier::Command.new(:cmd_name, argument_parser: argument_parser) do |c|
            c.action { |args| args }
          end
        end
        subject { @cmd }

        argument = :param
        subject { @cmd.run(*[parameter, :ignored]) }

        it { should be_a OpenStruct }
        its(:first_arg) { should == argument }
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

end
