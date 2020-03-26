require 'spec_helper'

require 'atelier/command'
require 'atelier/defaults'
require 'atelier/defaults/completion'

describe Atelier::Defaults::Completion do
  describe ".factory" do
    let(:command) { Atelier::Command.new(:cmd_name) }

    it "returns a DefaultCommand" do
      expect(subject.factory(command)).to be_a Atelier::DefaultCommand
    end
  end

  describe "command behavior" do
    let(:command) do
      Atelier::Command.new(:cmd_name) {}
    end

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      command.run(:completion)
      printed
    end

    it 'outputs shellscript that enable the bash completion' do
      is_expected.to match '^complete -o bashdefault -o default -F __completion__handler '
    end
  end
end
