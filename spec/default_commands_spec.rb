require 'spec_helper'

require 'atelier/command'

describe 'default commands' do
  subject { Atelier::Command.new(:cmd_name) {} }

  describe 'help' do
    expected_title = 'This is a dummy test command'

    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.title = expected_title
        c.command :sub_command do
        end
      end
    end

    subject do
      printed = ''
      STDOUT.stub(:puts) { |output| printed << output }
      @cmd.run(:help)
      printed
    end

    describe 'command description' do
      it { should match 'cmd_name' }
      it { should match expected_title }
    end

    describe 'default commands' do
      it { should match 'help' }
      it { should match 'completion' }
      it { should match 'complete' }
      it { should match 'commands' }
    end

    describe 'commands' do
      it { should match 'sub_command' }
    end
  end

  describe 'complete' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) do |c|
        c.command :sub_command do |s|
          s.command :sub_sub_command do
          end
        end
      end
    end

    let(:parameters) { [] }

    subject do
      printed = ''
      STDOUT.stub(:puts) { |output| printed << output }
      @cmd.run(:complete, *parameters)
      printed.lines.map(&:strip)
    end

    # full_completion_list files
    files  = Dir['*']
    files += Dir['.*']
    files -= ['.', '..']

    # full_completion_list sub-commands
    default_commands = ['commands', 'help', 'completion', 'complete' ]
    commands = ['sub_command']

    context 'without any parameters' do
      let(:parameters) { [] }

      it { should match_array files + default_commands + commands }
    end

    context 'with a file' do
      expected_file = Dir['*'].first
      let(:parameters) { [expected_file[0..-2]] }

      it { should match_array [expected_file] }
    end

    context 'with a sub command' do
      let(:parameters) { ['com'] }

      it { should match_array (files + default_commands + commands).grep(/^com/) }
    end

    context 'with a sub sub command' do
      let(:parameters) { ['sub_command', ''] }

      it { should match_array files + default_commands + ['sub_sub_command'] }
    end

  end

  describe 'completion' do
    before(:all) do
      @cmd = Atelier::Command.new(:cmd_name) {}
    end

    subject do
      printed = ''
      STDOUT.stub(:puts) { |output| printed << output }
      @cmd.run(:completion)
      printed
    end

    it 'should output shellscript that enable the bash completion' do
      subject.should match '^[ ]+complete '
    end
  end

end
