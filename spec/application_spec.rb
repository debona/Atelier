require 'spec_helper'

require 'atelier/application'

describe Atelier::Application do
  before { subject.logger.level = Logger::FATAL }

  its(:root_command) { is_expected.to eq nil }
  its(:logger) { is_expected.to be_a Logger }

  describe '#define_root_command' do
    it 'defines the application root_command' do
      expect {
        subject.define_root_command(:root_command) {}
      }.to change { subject.root_command }.from(nil).to an_instance_of(Atelier::Command)
    end

    it 'loads the root_command synchronously' do
      executed = false
      subject.define_root_command(:root_command) { executed = true }
      expect(executed).to eq true
    end

    it 'creates the app root_command according to the given parameters' do
      subject.define_root_command(:root_command, default: true) {}
      expect(subject.root_command.name).to eq :root_command
      expect(subject.root_command).to be_default
    end
  end

  describe '#run' do
    context 'when root_command is defined' do
      let(:root_command) { double(:root_command) }
      before { allow(subject).to receive(:root_command).and_return(root_command) }

      it 'forwards the call on the root_command' do
        expect(root_command).to receive(:run).with('one', 'two', 'three')
        subject.run('one', 'two', 'three')
      end

      it 'logs an error on exception' do
        e = RuntimeError.new('an exception')
        expect(root_command).to receive(:run) { raise e }

        expect(subject.logger).to receive(:error).with(e)
        subject.run
      end
    end
  end

  describe '#locate_command' do
    let(:located_command) { subject.locate_command(file_name) }

    context 'with a file available from the $PATH' do
      let(:file_name) { :bash }
      it { expect(located_command).to eq '/bin/bash' }
    end

    context 'with a file not available from the $PATH' do
      let(:file_name) { :qsgfqDs }
      it { expect(located_command).to be_nil }
    end
  end
end
