require 'spec_helper'

require 'atelier/command'
require 'atelier/defaults'
require 'atelier/defaults/help'

describe Atelier::Defaults::Help do
  describe ".factory" do
    let(:command) { Atelier::Command.new(:cmd_name) }

    it "returns a DefaultCommand" do
      expect(subject.factory(command)).to be_a Atelier::DefaultCommand
    end
  end

  describe "command behavior" do
    expected_title       = 'This is a dummy test command'
    expected_opt_switch  = '--an_option'
    expected_opt_desc    = 'An option'

    let(:command) do
      Atelier::Command.new(:cmd_name) do |c|
        c.title = expected_title
        c.option :an_option, expected_opt_switch, expected_opt_desc
        c.command :sub_command do
        end
      end
    end

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      command.run(:help)
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
      Atelier::Defaults::ALL.each do |default_name|
        it { is_expected.to match default_name.to_s }
      end
    end

    describe 'commands' do
      it { is_expected.to match 'sub_command' }
    end
  end
end
