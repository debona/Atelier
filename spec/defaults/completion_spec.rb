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

    let(:args) { [] }

    subject do
      printed = ''
      allow(STDOUT).to receive(:puts) { |output| printed << output }
      command.run(:completion, *args)
      printed
    end

    it 'outputs shellscript that enable the bash completion' do
      # As completion relies on $PROGRAM_NAME, it try to complete the `rspec` program
      is_expected.to match '^complete -o bashdefault -o default -F __completion__handler "rspec"'
    end

    context do
      let(:args) { ['foo'] }

      it 'outputs shellscript that enable the bash completion for the given program_name' do
        is_expected.to match '^complete -o bashdefault -o default -F __completion__handler "foo"'
      end
    end
  end
end
