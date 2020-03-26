require 'spec_helper'

require 'atelier/command'
require 'atelier/defaults'
require 'atelier/defaults/commands'

describe Atelier::Defaults::Commands do
  describe ".factory" do
    let(:command) { Atelier::Command.new(:cmd_name) }

    it "returns a DefaultCommand" do
      expect(subject.factory(command)).to be_a Atelier::DefaultCommand
    end
  end

  describe "command behavior" do
    let(:command) do
      Atelier::Command.new(:cmd_name) do |c|
        c.command :sub_command do |s|
          s.command :sub_sub_command do
          end
        end
        c.command :another_sub_command do
        end
      end
    end

    subject do
      printed = []
      allow(STDOUT).to receive(:puts) { |output| printed << output.to_s.strip }
      command.run(:commands)
      printed
    end

    it { is_expected.to match_array Atelier::Defaults::ALL.map(&:to_s) + ['sub_command', 'another_sub_command'] }
  end
end
