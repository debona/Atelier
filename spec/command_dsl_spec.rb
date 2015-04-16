require 'spec_helper'

require 'atelier/application'
require 'atelier/command_dsl'


describe Atelier::CommandDSL do

  class CmdClass
    include Atelier::CommandDSL

    attr_accessor :commands, :arguments_parser

  end

  before(:all) { @command = CmdClass.new }
  subject { @command }

  describe 'attributes' do
    [
      :title,
      :description
    ].each do |attr_name|
      describe "##{attr_name}" do
        value = "This is the #{attr_name} value"
        before { @command.send(attr_name, value) }

        its(attr_name) { should == value }
      end
    end
  end

  describe '#method' do
    before(:all) do
      @command = CmdClass.new
      @command.send(:method, :method_name) {}
    end
    subject { @command }

    its(:methods) { should include :method_name }
  end

  describe '#param' do
    before(:all) do
      @command = CmdClass.new
      @command.arguments_parser = Object.new
    end
    subject { @command }

    it 'should delegate the arguments parsing description' do
      subject.arguments_parser.should_receive(:param).with(:param_name)
      subject.param(:param_name)
    end
  end

  describe '#params' do
    before(:all) do
      @command = CmdClass.new
      @command.arguments_parser = Object.new
    end
    subject { @command }

    it 'should delegate the arguments parsing description' do
      subject.arguments_parser.should_receive(:params).with(:param_name)
      subject.params(:param_name)
    end
  end

  describe '#action' do
    expected_proc = Proc.new { :overriden }
    before(:all) do
      @command = CmdClass.new
      @command.send(:action, &expected_proc)
    end
    subject { @command }

    its(:action) { should == expected_proc }
  end

  describe '#command' do
    before(:all) { @command = CmdClass.new }

    it 'should NOT trigger the app run method' do
      Atelier::Application.instance.should_not_receive(:run)
      @command.send(:command, :sub_cmd_name) {}
    end

    describe 'created subcommand' do
      before(:all) { @command.send(:command, :sub_cmd_name) {} }

      subject { @command.commands[:sub_cmd_name] }

      it { should be_a Atelier::Command }

      its(:name)          { should == :sub_cmd_name }
      its(:super_command) { should == @command }
    end

  end

  describe '#load_command' do
    cmd_path = './spec/fixtures/loaded.rb'

    before do
      @command = CmdClass.new
      @command.send(:load_command, cmd_path)
    end

    it 'should properly load the command as a ruby file' do
      TOPLEVEL_BINDING.eval('@loaded_properly').should be_true
    end
  end

end
