require 'rask/application'
require 'rask/library_dsl'


describe Rask::LibraryDSL do

  class LibClass
    include Rask::LibraryDSL
  end

  before(:all) { @library = LibClass.new }
  subject { @library }

  describe 'attributes' do
    [
      :title,
      :description
    ].each do |attr_name|
      describe "##{attr_name}" do
        value = "This is the #{attr_name} value"
        before { @library.send(attr_name, value) }

        its(attr_name) { should == value }
      end
    end
  end

  describe '#method' do
    before(:all) do
      @library = LibClass.new
      @library.send(:method, :method_name) {}
    end
    subject { @library }

    its(:methods) { should include :method_name }
  end

  describe '#action' do
    context 'with trivial value' do
      before(:all) do
        @library = LibClass.new
        @library.send(:action, :action_one) {}
      end
      subject { @library }

      its(:methods) { should include :action_one }
    end

    context 'with an already given action name' do
      before do
        @library = LibClass.new
        @library.send(:action, :action_one) { block { :original_result } }
      end
      subject { @library }

      it 'should override the action with a warning' do
        Rask::Application.instance.logger.should_receive(:warn)
        @library.send(:action, :action_one) { block { :overriden_result } }
        subject.action_one.should == :overriden_result
      end
    end
  end

  describe '#library' do
    before(:all) do
      @library = LibClass.new
      @library.send(:library, :sub_lib_name) {}
    end

    subject { @library.send(:sub_lib_name) }

    it { should be_a Rask::Library }
    its(:name)    { should == :sub_lib_name }
  end

end