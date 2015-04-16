require 'spec_helper'

require 'atelier/command'

describe Atelier::Command do

  describe '#initialize' do
    subject { Atelier::Command.new(:cmd_name) {} }
    its(:name) { should == :cmd_name }

    context 'with options' do
      expected_options = {
        default:     :something_true,
        title:       :expected_title,
        description: :expected_description,
        commands:    :expected_commands,
        action:      :expected_action
      }
      subject { Atelier::Command.new(:cmd_name, expected_options) {} }

      its(:default?) { should == true }

      [:title, :description, :commands, :action].each do |option_name|
        its(option_name) { should == expected_options[option_name] }
      end
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
          arguments_parser = Atelier::ArgumentsParser.new
          arguments_parser.param(:first_arg)
          @cmd = Atelier::Command.new(:cmd_name, arguments_parser: arguments_parser) do |c|
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
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.command(:sub_cmd_name) { |s| s.method(:sub_method) { :expected_result } }
      end
    end

    subject { @cmd.commands }

    it { should have(5).item }
    its([:sub_cmd_name]) { should be_a Atelier::Command }
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
