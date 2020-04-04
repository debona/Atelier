require 'spec_helper'

require 'atelier/defaults'

describe Atelier::Defaults do
  describe "::ALL" do
    it { expect(subject::ALL).to eq [:help, :completion, :complete] }
  end

  describe ".factory" do
    let(:command) { Atelier::Command.new(:command) }

    context "when the default_name does not exist" do
      it "raise an ArgumentError" do
        expect {
          subject.factory('does_not_exists', command)
        }.to raise_error(ArgumentError, "DefaultCommand does_not_exists not found")
      end
    end

    context "when the default_name exists" do
      it "delegates to the factory" do
        expect(Atelier::Defaults::Help).to receive(:factory).with(command)
        subject.factory('help', command)
      end
    end
  end
end
