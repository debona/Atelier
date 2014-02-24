require 'spec_helper'

require 'atelier/library'

describe Atelier::Command do

  describe '#initialize' do
    subject { Atelier::Command.new(:cmd_name) {} }
    its(:name) { should == :cmd_name }
  end

  describe '#run' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do
        action(:action_name) { block { |*params| params } }
      end
    end
    subject { @cmd }

    context 'with an existing action' do
      parameter       = :param
      expected_result = [parameter]
      subject { @cmd.run(:action_name, parameter) }

      it { should be_a Array }
      it { should == expected_result }
    end

    context 'with a sub-command' do
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

    context 'with a wrong action' do
      it 'should raise an error' do
        expect { subject.run(:wrong_action, 'param1', 'param2') }.to raise_error
      end
    end
  end

  describe '#actions' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do
        action(:action_name) { block { :expected_result } }
      end
    end
    subject { @cmd.actions }

    it { should_not be_empty }
    its([:action_name]) { should be_a Atelier::Action }
  end

  describe 'commands' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do
        command(:sub_cmd_name) { method(:sub_method) { :expected_result } }
      end
    end

    describe '#commands' do
      subject { @cmd.commands }

      it { should have(1).item }
      its([:sub_cmd_name]) { should be_a Atelier::Command }
    end

    describe '#sub_cmd_name' do
      subject { @cmd.sub_cmd_name }

      it { should be_a Atelier::Command }
    end
  end

  describe 'default actions' do
    before(:all) { @cmd = Atelier::Command.new(:cmd_name) {} }
    subject      { @cmd.actions }

    it { should include :help }
    it { should include :actions }
    it { should include :commands }
  end

end
