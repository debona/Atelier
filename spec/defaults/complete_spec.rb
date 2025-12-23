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
      Atelier::Command.new(:cmd_name) { }
    end

    let(:argv) { ['first', 'middle', 'last'] }

    subject(:printed_completion) do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      command.run(:complete, *argv)
      printed
    end

    let(:results) { ['result1', 'result2', 'result3'] }

    before do
      allow(command).to receive(:complete).and_return(results)
    end

    it "delegates to the complete method forwarding all args" do
      printed_completion
      expect(command).to have_received(:complete).with(*argv)
    end

    it "puts all the complete results" do
      expected_results = results.join("\n")
      expect(printed_completion).to eq(expected_results)
    end
  end
end
