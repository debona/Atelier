require 'spec_helper'

require 'atelier/library'

describe Atelier::Library do

  describe '#initialize' do
    subject { Atelier::Library.new(:lib_name) {} }
    its(:name) { should == :lib_name }
  end

  describe '#run' do
    before(:all) do
      @lib = Atelier::Library.new(:lib_name) do
        action(:action_name) { block { |*params| params } }
      end
    end
    subject { @lib }

    context 'with an existing action' do
      parameter       = :param
      expected_result = [parameter]
      subject { @lib.run(:action_name, parameter) }

      it { should be_a Array }
      it { should == expected_result }
    end

    context 'with a sub-library' do
      before(:all) do
        @lib = Atelier::Library.new(:lib_name) do
          library(:sub_lib_name) { }
        end
      end
      subject { @lib }

      it 'should call `run` on the sub-library' do
        subject.libraries[:sub_lib_name].should_receive(:run).with(:action_name, :param)
        subject.run(:sub_lib_name, :action_name, :param)
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
      @lib = Atelier::Library.new(:lib_name) do
        action(:action_name) { block { :expected_result } }
      end
    end
    subject { @lib.actions }

    it { should_not be_empty }
    its([:action_name]) { should be_a Atelier::Action }
  end

  describe 'libraries' do
    before(:all) do
      @lib = Atelier::Library.new(:lib_name) do
        library(:sub_lib_name) { method(:sub_method) { :expected_result } }
      end
    end

    describe '#libraries' do
      subject { @lib.libraries }

      it { should have(1).item }
      its([:sub_lib_name]) { should be_a Atelier::Library }
    end

    describe '#sub_lib_name' do
      subject { @lib.sub_lib_name }

      it { should be_a Atelier::Library }
    end
  end

  describe '#help' do
    before(:all) do
      @lib = Atelier::Library.new(:lib_name) do
        action(:action_name) { block { :expected_result } }
      end
    end
    subject { @lib }

    its(:methods) { should include :help }
    its(:actions) { should include :help }
  end

end
