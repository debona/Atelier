require 'rask/application'
require 'rask/factory'

describe Rask::Factory do

  before(:all) { @factory = Rask::Factory.new }
  subject { @factory }

  describe '.create' do
    context 'without any parameters' do
      specify { expect { @factory.create() {} }.to raise_error ArgumentError }
    end

    context 'providing name' do
      subject { @factory.create(:lib_name) {} }
      its(:name)    { should == :lib_name }
    end

    context 'providing actions' do
      subject { @factory.create(:lib_name) { action(:action_name) {} } }
      its(:methods)                { should include :action_name }
    end
  end

  describe '#method' do
    method_proc = Proc.new { :result }
    before(:all) do
      @lib = @factory.create(:lib_name) {}
      @factory.send(:method, :method_name, &method_proc)
    end
    subject { @lib }

    its(:methods) { should include :method_name }
    its(:method_name) { should == method_proc.call }
  end

  describe '#action' do
    context 'with trivial value' do
      action_proc = Proc.new { :result }
      before(:all) do
        @lib = @factory.create(:lib_name) {}
        @factory.send(:action, :action_one, &action_proc)
      end

      subject { @lib }

      its(:methods) { should include :action_one }
      its(:action_one) { should == action_proc.call }
    end

    context 'with an already given action name' do
      expected_result = :expected_result
      before(:all) do
        @lib = @factory.create(:lib_name) {}
        @factory.send(:action, :action_one) {}
        @factory.send(:action, :action_one) { expected_result }
      end

      subject { @lib }

      it 'should display a warning' do
        Rask::Application.instance.logger.should_receive(:warn)
        @factory.send(:action, :action_one) { expected_result }
      end

      its(:action_one) { expected_result }
    end
  end

end