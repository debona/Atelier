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
        expect(subject.application).to receive(:load_root_command).with(:name, an_option: nil, &expected_block)
        subject.command(:name, an_option: nil, &expected_block)
      end

      it 'defines the application root_command' do
        expect {
          subject.command(:name) {}
        }.to change { subject.application.root_command }.from(nil).to an_instance_of(Atelier::Command)
      end

      it 'triggers the app run method' do
        if ARGV.any?
          expect(subject.application).to receive(:run).with(*ARGV)
        else
          expect(subject.application).to receive(:run).with(no_args)
        end
        subject.command(:name) {}
      end
    end

    context 'when there is an application root_command and a loading command' do
      it 'forwards the command call on the loading command' do
        subject.command(:root_command) do
          expect(subject.application.loading_command).to receive(:command).with(:new_cmd, {}, &expected_block)
          subject.command(:new_cmd, {}, &expected_block)
        end
      end
    end
  end
end
