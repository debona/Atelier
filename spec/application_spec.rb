require 'spec_helper'

require 'atelier/application'

describe Atelier::Application do
  before(:all) do
    @app = Atelier::Application.instance
  end
  before { allow(@app.logger).to receive(:warn).and_return(nil) }
  subject { @app }

  describe '.instance' do
    its(:logger) { is_expected.to be_a Logger }
  end

  describe '#load_root_command' do
    name = :cmd_name

    before { @app.load_root_command(name) {} }
    subject { @app.root_command }

    it { is_expected.to be_a Atelier::Command }
    its(:name) { is_expected.to eq name }

    context 'when a root command is already defined' do
      it 'logs a warning' do
        expect(@app.logger).to receive(:warn)
        @app.load_root_command(:another, {}) {}
      end

      it 'overrides the root command' do
        @app.load_root_command(:override, {}) {}
        expect(@app.root_command.name).to eq :override
      end
    end
  end

  describe '#loading_command' do
    subject { @app.loading_command }

    context 'while there is no loading command' do
      it { is_expected.to eq nil }
    end

    context 'while the root command is loading' do
      it 'returns the root command' do
        @app.load_root_command(:root_command) { |r| expect(subject).to eq r }
      end
    end

    context 'while commands are loading' do
      it 'returns the sub command' do
        @app.load_root_command(:root_command) do |r|
          r.command(:command) do |c|
            c.command(:another_command) { |a| expect(subject).to eq a }
          end
        end
      end
    end
  end

  describe '#run' do
    context 'when root_command is defined' do
      subject { @app }

      it 'runs the :sample_command on the root_command' do
        root_command = Object.new
        expect(root_command).to receive(:run).with(:sample_command)
        expect(subject).to receive(:root_command).and_return(root_command)

        subject.run(:sample_command)
      end

      it 'logs an error on exception' do
        e = RuntimeError.new('an exception')
        root_command = Object.new
        expect(root_command).to receive(:run) { raise e }
        expect(subject).to receive(:root_command).and_return(root_command)

        expect(subject.logger).to receive(:error).with(e)
        subject.run(:sample_command)
      end
    end
  end

  describe '#locate_command' do
    subject { @app.locate_command(file_name) }

    context 'with a file available from the $PATH' do
      let(:file_name) { :bash }
      it { is_expected.to eq '/bin/bash' }
    end

    context 'with a file not available from the $PATH' do
      let(:file_name) { :qsgfqDs }
      it { is_expected.to be_nil }
    end
  end

end
