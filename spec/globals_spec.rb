require 'spec_helper'

require 'atelier/globals'

describe Atelier::Globals do

  describe ".application" do
    it { expect(subject.application).to be_a Atelier::Application }

    it "returns every time the same application" do
      expect(subject.application).to eq subject.application
    end
  end

  describe '.command' do
    # Ensure the application is always clean
    before { allow(subject).to receive(:application).and_return(Atelier::Application.new) }

    let(:expected_block) { Proc.new {} }

    context 'when there is no application root_command yet' do
      it 'loads the command as the root one' do
        allow(subject.application).to receive(:run)
        expect(subject.application).to receive(:define_root_command).with(:name, an_option: nil, &expected_block)
        subject.command(:name, an_option: nil, &expected_block)
      end

      it 'loads the application root_command synchronously' do
        expect {
          subject.command(:name) {}
        }.to change { subject.application.root_command }.from(nil).to an_instance_of(Atelier::Command)
      end

      it 'calls the application run method' do
        if ARGV.any?
          expect(subject.application).to receive(:run).with(*ARGV)
        else
          expect(subject.application).to receive(:run).with(no_args)
        end
        subject.command(:name) {}
      end
    end

    context 'when the root_command is loading' do
      it 'forwards the command call on the root_command loading command' do
        subject.command(:root_command) do |root_command|
          loading_command = double(:loading_command)
          allow(root_command).to receive(:loading_command).and_return(loading_command)
          expect(loading_command).to receive(:command).with(:new_cmd, {}, &expected_block)
          subject.command(:new_cmd, {}, &expected_block)
        end
      end
    end
  end
end
