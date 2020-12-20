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
      subject.define_root_command(:root_command, defaults: []) {}
      expect(subject.root_command.name).to eq :root_command
      expect(subject.root_command.defaults).to eq []
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

      context 'when there is an exception' do
        e = RuntimeError.new('an exception')
        before { expect(root_command).to receive(:run) { raise e } }

        it 'logs an error on exception' do
          expect(subject.logger).to receive(:error).with(e)
          subject.run
        end

        it 'returns the exception' do
          expect(subject.logger).to receive(:error)
          expect(subject.run).to eq e
        end
      end
    end
  end

  describe '#request_command_load' do
    let(:command) { Atelier::Command.new(:command_name) }

    it "loads the command file" do
      expect(subject).to receive(:load).with('loaded_command')
      subject.request_command_load(command, 'loaded_command')
    end

    it "mimics the require behavior when the .rb extention is omitted" do
      expect(subject).to receive(:load).with('loaded_command').and_raise(LoadError.new)
      expect(subject).to receive(:load).with('loaded_command.rb')
      subject.request_command_load(command, 'loaded_command')
    end
  end

  describe '#command_load_requested?' do
    let(:command) { Atelier::Command.new(:command_name) }

    it "is true only while the command is loading" do
      expect(subject.command_load_requested?).to eq false
      expect(subject).to receive(:load) do
        expect(subject.command_load_requested?).to eq true
      end
      subject.request_command_load(command, 'loaded_command')
      expect(subject.command_load_requested?).to eq false
    end
  end

  describe '#load_requested_command' do
    expected_block = Proc.new { :expected_block }
    let(:command) { Atelier::Command.new(:command_name) }

    it "forward the command loading while request_command_load is called" do
      expect(subject).to receive(:load) do
        expect(command).to receive(:command).with('name',  opt1: true, &expected_block)
        subject.load_requested_command('name',  opt1: true, &expected_block)
      end
      subject.request_command_load(command, 'loaded_command')
    end
  end
end
