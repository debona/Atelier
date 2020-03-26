require 'spec_helper'

require 'atelier/command'
require 'atelier/defaults'
require 'atelier/defaults/complete'

describe Atelier::Defaults::Complete do
  describe ".factory" do
    let(:command) { Atelier::Command.new(:cmd_name) }

    it "returns a DefaultCommand" do
      expect(subject.factory(command)).to be_a Atelier::DefaultCommand
    end
  end

  describe "command behavior" do
    let(:command) do
      Atelier::Command.new(:cmd_name) do |c|
        c.option(:option, '-o', '--option OPT', 'test purpose option') { ["value1", "value2"] }
        c.option(:option, '-a', '--alert ALERT', 'test purpose option')
        c.command :sub_command do |s|
          s.command :sub_sub_command do
          end
        end
      end
    end

    let(:argv) { [] }

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      command.run(:complete, *argv)
      printed.lines.map(&:strip)
    end

    # full_completion_list files
    files  = Dir['*']
    files -= ['.', '..']

    # full_completion_list sub-commands
    default_commands = Atelier::Defaults::ALL.map(&:to_s)
    commands = ['sub_command']
    options = ['-o', '--option', '-a', '--alert']

    context 'without any args' do
      let(:argv) { [] }

      it { is_expected.to match_array files + default_commands + commands + options }
    end

    context 'with a file' do
      expected_file = Dir['*'].first
      let(:argv) { [expected_file[0..-2]] }

      it { is_expected.to match_array [expected_file] }
    end

    context 'with an option' do
      let(:argv) { ['--op'] }

      it { is_expected.to match_array ['--option'] }
    end

    context 'with a sub command' do
      let(:argv) { ['com'] }

      it { is_expected.to match_array (files + default_commands + commands).grep(/^com/) }
    end

    context 'with several args' do

      context 'begining with an option with a completion block' do
        let(:argv) { ['--option', ''] }

        it { is_expected.to match_array ["value1", "value2"] }
      end

      context 'begining with an option without completion block' do
        let(:argv) { ['--alert', ''] }

        it { is_expected.to match_array files + options }
      end

      context 'begining with NOT a sub command' do
        let(:argv) { ['not_sub_command', ''] }

        it { is_expected.to match_array files + options }
      end

      context 'begining with a sub command' do
        it 'forwards the completion to the matching sub command' do
          expect(command.sub_commands_hash[:sub_command]).to receive(:run).with(:complete, '')
          command.run(:complete, 'sub_command', '')
        end
      end
    end
  end
end
