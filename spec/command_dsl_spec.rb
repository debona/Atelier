require 'spec_helper'

require 'atelier/application'
require 'atelier/command_dsl'

describe Atelier::CommandDSL do

  class CmdClass
    include Atelier::CommandDSL

    attr_accessor :commands

    def application
      @application ||= Atelier::Application.new
    end
  end

  subject { CmdClass.new }

  describe '#action' do
    expected_proc = Proc.new { :overriden }
    before { subject.action(&expected_proc) }

    its(:action) { is_expected.to eq expected_proc }
  end

  describe '#command' do
    it 'does NOT trigger the run method' do
      expect(subject).to_not receive(:run)
      subject.command(:sub_cmd_name) {}
    end

    describe 'created subcommand' do
      before { subject.command(:sub_cmd_name) {} }

      let(:subcommand) { subject.commands[:sub_cmd_name] }

      it { expect(subcommand).to be_a Atelier::Command }

      it { expect(subcommand.name).to eq :sub_cmd_name }

      it 'subcommand super_command equals the command' do
        expect(subcommand.super_command).to eq subject
      end
    end

  end

  describe '#load_command' do
    cmd_path = 'spec/fixtures/loaded.rb'

    before { subject.load_command(cmd_path) }

    it 'loads the command as a ruby file' do
      expect(TOPLEVEL_BINDING.eval('@loaded_properly')).to eq true
    end
  end

end
