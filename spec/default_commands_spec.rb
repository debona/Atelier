require 'spec_helper'

require 'atelier/command'

describe 'default command' do
  subject { Atelier::Command.new(:cmd_name) {} }

  default_commands = ['commands', 'help', 'completion', 'complete' ]

  describe 'commands' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.command :sub_command do |s|
          s.command :sub_sub_command do
          end
        end
      end
    end

    subject do
      printed = []
      allow(STDOUT).to receive(:puts) { |output| printed << output.to_s.strip }
      @cmd.run(:commands)
      printed
    end

    sub_commands = ['sub_command']

    it { is_expected.to match_array default_commands + sub_commands }
  end

  describe 'help' do
    expected_title       = 'This is a dummy test command'
    expected_opt_switch  = '--an_option'
    expected_opt_desc    = 'An option'

    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.title = expected_title
        c.option :an_option, expected_opt_switch, expected_opt_desc
        c.command :sub_command do
        end
      end
    end

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      @cmd.run(:help)
      printed
    end

    describe 'command description' do
      it { is_expected.to match 'cmd_name' }
      it { is_expected.to match expected_title }
    end

    describe 'options' do
      it { is_expected.to match expected_opt_switch }
      it { is_expected.to match expected_opt_desc }
    end

    describe 'default commands' do
      it { is_expected.to match 'help' }
      it { is_expected.to match 'completion' }
      it { is_expected.to match 'complete' }
      it { is_expected.to match 'commands' }
    end

    describe 'commands' do
      it { is_expected.to match 'sub_command' }
    end
  end

  describe 'complete' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.option(:option, '-o', '--option OPT', 'test purpose option') { ["value1", "value2"] }
        c.option(:option, '-a', '--alert ALERT', 'test purpose option')
        c.command :sub_command do |s|
          s.command :sub_sub_command do
          end
        end
      end
    end

    let(:parameters) { [] }

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      @cmd.run(:complete, *parameters)
      printed.lines.map(&:strip)
    end

    # full_completion_list files
    files  = Dir['*']
    files -= ['.', '..']

    # full_completion_list sub-commands
    default_commands = ['commands', 'help', 'completion', 'complete' ]
    commands = ['sub_command']
    options = ['-o', '--option', '-a', '--alert']

    context 'without any parameters' do
      let(:parameters) { [] }

      it { is_expected.to match_array files + default_commands + commands + options }
    end

    context 'with a file' do
      expected_file = Dir['*'].first
      let(:parameters) { [expected_file[0..-2]] }

      it { is_expected.to match_array [expected_file] }
    end

    context 'with an option' do
      let(:parameters) { ['--op'] }

      it { is_expected.to match_array ['--option'] }
    end

    context 'with a sub command' do
      let(:parameters) { ['com'] }

      it { is_expected.to match_array (files + default_commands + commands).grep(/^com/) }
    end

    context 'with several parameters' do

      context 'begining with an option with a completion block' do
        let(:parameters) { ['--option', ''] }

        it { is_expected.to match_array ["value1", "value2"] }
      end

      context 'begining with an option without completion block' do
        let(:parameters) { ['--alert', ''] }

        it { is_expected.to match_array files + options }
      end

      context 'begining with NOT a sub command' do
        let(:parameters) { ['not_sub_command', ''] }

        it { is_expected.to match_array files + options }
      end

      context 'begining with a sub command' do
        it 'forwards the completion to the matching sub command' do
          expect(@cmd.sub_commands_hash[:sub_command]).to receive(:run).with(:complete, '')
          @cmd.run(:complete, 'sub_command', '')
        end
      end
    end
  end

  describe 'completion' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) {}
    end

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      @cmd.run(:completion)
      printed
    end

    it 'outputs shellscript that enable the bash completion' do
      is_expected.to match '^[ ]+complete '
    end
  end

end
