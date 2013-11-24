require 'rask/library'
require 'rask/factory'

describe Rask::Library do

  describe '#initialize' do
    subject { Rask::Library.new(:lib_name) }
    its(:name) { should == :lib_name }
  end

  describe 'actions' do
    before(:all) do
      @lib = Rask::Factory.new.create(:lib_name) { action(:action_name) { :expected_result } }
    end
    subject { @lib }

    its(:action_name) { should == :expected_result }
  end

  describe 'methods' do
    before(:all) do
      @lib = Rask::Factory.new.create(:lib_name) { method(:method_name) { :expected_result } }
    end
    subject { @lib }

    its(:method_name) { should == :expected_result }
  end

end