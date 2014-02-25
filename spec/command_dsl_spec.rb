require 'spec_helper'

require 'atelier/application'
require 'atelier/command_dsl'


describe Atelier::CommandDSL do

  class CmdClass
    include Atelier::CommandDSL

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
    before(:all) do
      @command = CmdClass.new
      @command.send(:command, :sub_cmd_name) {}
    end

    subject { @command.send(:sub_cmd_name) }

    it { should be_a Atelier::Command }
    its(:name)    { should == :sub_cmd_name }
  end

  describe '#load_command' do
    cmd_path = 'spec/fixtures/loaded.rb'

    before do
      @command = CmdClass.new
      @command.send(:load_command, cmd_path)
    end

    it 'should properly load the command as a ruby file' do
      @command.instance_eval { @loaded_properly }.should be_true
    end
  end

end
