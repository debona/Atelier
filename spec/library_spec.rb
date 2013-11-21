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

end