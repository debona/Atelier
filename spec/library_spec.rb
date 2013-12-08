require 'rask/library'

describe Rask::Library do

  describe '#initialize' do
    subject { Rask::Library.new(:lib_name) {} }
    its(:name) { should == :lib_name }
  end

  describe 'actions' do
    before(:all) do
      @lib = Rask::Library.new(:lib_name) do
        action(:action_name) { block { :expected_result } }
      end
    end
    subject { @lib }

    its(:action_name) { should == :expected_result }

    describe 'its actions' do
      subject { @lib.actions }

      it { should_not be_empty }
      its([:action_name]) { should be_a Rask::Action }
    end
  end

  describe 'methods' do
    before(:all) do
      @lib = Rask::Library.new(:lib_name) { method(:method_name) { :expected_result } }
    end
    subject { @lib }

    its(:method_name) { should == :expected_result }
  end

  describe 'libraries' do
    before(:all) do
      @lib = Rask::Library.new(:lib_name) do
        library(:sub_lib_name) { method(:sub_method) { :expected_result } }
      end
    end

    describe 'its libraries' do
      subject { @lib.libraries }

      it { should have(1).item }
      its([:sub_lib_name]) { should be_a Rask::Library }
    end

    describe '#sub_lib_name' do
      subject { @lib }

      context 'without parameters' do
        its(:sub_lib_name) { should be_a Rask::Library }
      end

      context 'with parameters' do
        it 'should chain the messages and return the result' do
          subject.sub_lib_name(:sub_method).should == :expected_result
        end
      end
    end

  end

end
