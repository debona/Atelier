require 'spec_helper'

require 'atelier/command'

describe Atelier::Command do

  describe '#initialize' do
    subject { Atelier::Command.new(:cmd_name) {} }
    its(:name) { should == :cmd_name }
  end

  describe '#run' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do
        action { |*params| params }
      end
    end
    subject { @cmd }

    context 'with parameters' do
      parameter       = :param
      expected_result = [parameter]
      subject { @cmd.run(parameter) }

      it { should be_a Array }
      it { should == expected_result }
    end

    context 'with an existing sub-command' do
      before(:all) do
        @cmd = Atelier::Command.new(:cmd_name) do
          command(:sub_cmd_name) { }
        end
      end
      subject { @cmd }

      it 'should call `run` on the sub-command' do
        subject.commands[:sub_cmd_name].should_receive(:run).with(:action_name, :param)
        subject.run(:sub_cmd_name, :action_name, :param)
      end
    end
  end

  describe '#action' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do
        action { :expected_result }
      end
    end
    subject { @cmd.action }

    it { should be_a Proc }
  end

  describe 'commands' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do
        command(:sub_cmd_name) { method(:sub_method) { :expected_result } }
      end
    end

    describe '#commands' do
      subject { @cmd.commands }

      it { should have(3).item }
      its([:sub_cmd_name]) { should be_a Atelier::Command }
    end

    describe '#sub_cmd_name' do
      subject { @cmd.sub_cmd_name }

      it { should be_a Atelier::Command }
    end
  end

  describe 'default commands' do
    before(:all) { @cmd = Atelier::Command.new(:cmd_name) {} }
    subject      { @cmd.commands }

    it { should include :help }
    it { should include :commands }
  end

end
