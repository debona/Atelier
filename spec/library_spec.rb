require 'rask/library'

describe Rask::Library do

  describe '#initialize' do
    context 'without any parameters' do
      specify { expect { Rask::Library.new() {} }.to raise_error ArgumentError }
    end

    context 'providing name' do
      name = :LibName
      subject { Rask::Library.new(name) {} }

      its(:name) { should == name }
    end

    context 'providing actions' do
      action_name = :action_one

      subject { Rask::Library.new(:TestLibrary) { action(action_name) {} } }

      its(:methods) { should include action_name }
    end
  end

  describe '#action' do
    context 'with trivial value' do
      action_name = :action_one
      action_proc = Proc.new { :result }
      before(:all) do
        @lib = Rask::Library.new(:TestLibrary) {}
        @lib.send(:action, action_name, &action_proc)
      end

      subject { @lib }

      its(:methods) { should include action_name }
      its(action_name) { should == action_proc.call }
    end

    context 'with an already given action name' do
      action_name     = :action_one
      expected_result = :expected_result
      before(:all) do
        @lib = Rask::Library.new(:TestLibrary) {}
        @lib.send(:action, action_name) {}
        @lib.send(:action, action_name) { expected_result }
      end

      subject { @lib }

      it 'should display a warning' do
        Rask::Application.instance.logger.should_receive(:warn)
        @lib.send(:action, action_name) { expected_result }
      end

      its(action_name) { expected_result }
    end
  end

end