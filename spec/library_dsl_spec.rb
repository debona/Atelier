require 'atelier/application'
require 'atelier/library_dsl'


describe Atelier::LibraryDSL do

  class LibClass
    include Atelier::LibraryDSL
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
        Atelier::Application.instance.logger.should_receive(:warn)
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

    it { should be_a Atelier::Library }
    its(:name)    { should == :sub_lib_name }
  end

  describe '#load_library' do
    lib_path = 'spec/fixtures/loaded.rb'

    before do
      @library = LibClass.new
      @library.send(:load_library, lib_path)
    end

    it 'should properly load the library as a ruby file' do
      @library.instance_eval { @loaded_properly }.should be_true
    end
  end

end
