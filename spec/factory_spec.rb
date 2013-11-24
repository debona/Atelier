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
    before(:all) do
      @lib = @factory.create(:lib_name) {}
      @factory.send(:method, :method_name) {}
    end
    subject { @lib }

    its(:methods) { should include :method_name }
  end

  describe '#action' do
    context 'with trivial value' do
      before(:all) do
        @lib = @factory.create(:lib_name) {}
        @factory.send(:action, :action_one) {}
      end
      subject { @lib }

      its(:methods) { should include :action_one }
    end

    context 'with an already given action name' do
      before do
        @lib = @factory.create(:lib_name) {}
        @factory.send(:action, :action_one) { :original_result }
      end
      subject { @lib }

      it 'should override the action with a warning' do
        Rask::Application.instance.logger.should_receive(:warn)
        @factory.send(:action, :action_one) { :overriden_result }
        subject.action_one.should == :overriden_result
      end
    end
  end

  describe '#library' do
    before(:all) do
      @lib = @factory.create(:lib_name) {}
      @factory.send(:library, :sub_lib_name) {}
    end

    subject { @lib.send(:sub_lib_name) }

    it { should be_a Rask::Library }
    its(:name)    { should == :sub_lib_name }
  end

end