require 'spec_helper'

require 'atelier/application'

describe Atelier::Application do
  before(:all) { @app = Atelier::Application.instance }
  subject { @app }

  describe '.instance' do
    its(:logger) { should be_a Logger }
  end

  describe '#load_root_command' do
    name = :cmd_name

    before(:all) { @app.load_root_command(name) {} }
    subject { @app.root_command }

    it { should be_a Atelier::Command }
    its(:name) { should == name }
  end

  describe '#run' do
    context 'when root_command is defined' do
      subject { @app }

      it 'should run the :sample_command on the root_command' do
        root_command = Object.new
        root_command.should_receive(:run).with(:sample_command)
        subject.stub(:root_command) { root_command }

        subject.run(:sample_command)
      end
    end
  end

  describe '#locate_command' do
    subject { @app.locate_command(file_name) }

    context 'with a file available from the $PATH' do
      let(:file_name) { :bash }
      it { should == '/bin/bash' }
    end

    context 'with a file not available from the $PATH' do
      let(:file_name) { :qsgfqDs }
      it { should be_nil }
    end
  end

end
