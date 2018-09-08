require 'spec_helper'

require 'atelier/application'
require 'atelier/command_dsl'

require 'optparse'

describe Atelier::CommandDSL do

  class CmdClass
    include Atelier::CommandDSL

    attr_accessor :commands, :option_parser, :options_completions

    def application
      @application ||= Atelier::Application.new
    end
  end

  subject { CmdClass.new }

  before do
    subject.option_parser = OptionParser.new
  end

  describe '#option' do
    it 'delegates the options parsing description' do
      opt_parser_args = [:a, :b, :c]
      expect(subject.option_parser).to receive(:on).with(*opt_parser_args)
      subject.option(:option_name, *opt_parser_args)
    end

    context 'with a completion block' do
      expected_proc = Proc.new { :very_expected_proc }
      switches = ['-a', '-b', '--long-a', '--long-b']

      before { subject.option(:option_name, *switches, &expected_proc) }

      describe 'its options_completions' do
        it { expect(subject.options_completions).to be_a Hash }

        switches.each do |switch|
          it { expect(subject.options_completions[switch]).to eq expected_proc }
        end
      end
    end
  end

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
