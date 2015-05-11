require 'spec_helper'

require 'atelier/application'
require 'atelier/command_dsl'


describe Atelier::CommandDSL do

  class CmdClass
    include Atelier::CommandDSL

    attr_accessor :commands, :argument_parser, :option_parser

  end

  before(:all) { @command = CmdClass.new }
  subject { @command }

  describe '#param' do
    before(:all) do
      @command = CmdClass.new
      @command.argument_parser = Object.new
    end
    subject { @command }

    it 'should delegate the arguments parsing description' do
      subject.argument_parser.should_receive(:param).with(:param_name)
      subject.param(:param_name)
    end
  end

  describe '#option' do
    before(:all) do
      @command = CmdClass.new
      @command.option_parser = Object.new
    end
    subject { @command }

    it 'should delegate the options parsing description' do
      opt_parser_args = [:a, :b, :c]
      subject.option_parser.should_receive(:on).with(*opt_parser_args)
      subject.option(:option_name, *opt_parser_args)
    end
  end

  describe '#params' do
    before(:all) do
      @command = CmdClass.new
      @command.argument_parser = Object.new
    end
    subject { @command }

    it 'should delegate the arguments parsing description' do
      subject.argument_parser.should_receive(:params).with(:param_name)
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
      it 'its super_command should equal the command' do
        subject.super_command.should == @command
      end
    end

  end

  describe '#load_command' do
    cmd_path = 'spec/fixtures/loaded.rb'

    before do
      @command = CmdClass.new
      @command.send(:load_command, cmd_path)
    end

    it 'should properly load the command as a ruby file' do
      TOPLEVEL_BINDING.eval('@loaded_properly').should be_true
    end
  end

end
