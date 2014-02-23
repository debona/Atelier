require 'spec_helper'

require 'atelier/application'
require 'atelier/library_dsl'


describe Atelier::LibraryDSL do

  class LibClass
    include Atelier::LibraryDSL

    attr_reader :actions
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

      its(:actions) { should include :action_one }
    end

    context 'with an already given action name' do
      expected_proc = Proc.new { :overriden }
      before do
        @library = LibClass.new
        @library.send(:action, :action_one) { block { :original } }
      end
      subject { @library }

      it 'should log a warning' do
        Atelier::Application.instance.logger.should_receive(:warn)
        subject.send(:action, :action_one) { block(&expected_proc) }
      end

      it 'should override the action' do
        Atelier::Application.instance.logger.stub(:warn)
        subject.send(:action, :action_one) { block(&expected_proc) }
        subject.actions[:action_one].proc.should == expected_proc
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
