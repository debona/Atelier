require 'spec_helper'

require 'atelier/application'

describe Atelier::Application do
  before(:all) { @app = Atelier::Application.instance }
  subject { @app }

  describe '.instance' do
    pending { its(:root_command) { should be_nil } }
    its(:logger) { should be_a Logger }

    describe 'its side-effects' do
      it 'Kernel methods should include :command' do
        Kernel.methods.should include :command
      end

      it 'command should redirect to the app load_root_command method' do
        @app.should_receive(:load_root_command).with(:name)
        Kernel.command(:name) {}
      end
    end
  end

  describe '#load_root_command' do
    name = :cmd_name

    before(:all) { @app.load_root_command(name) {} }
    subject { @app.root_command }

    it { should be_a Atelier::Command }
    its(:name) { should == name }
  end

  describe '#run' do
    context 'with an existing command file' do
      subject { @app }

      it 'should load the command file as root command' do
        subject.run('spec/fixtures/sample.rb', :sample_command)
        subject.root_command.name.should == :sample
      end
      it 'should run the :sample_command on the root_command ' do
        root_command = Object.new
        root_command.should_receive(:run).with(:sample_command)
        subject.stub(:root_command) { root_command }
        subject.run('spec/fixtures/sample.rb', :sample_command)
      end
    end

    context 'with wrong command' do
      it 'should display an error' do
        @app.logger.should_receive(:error)
        @app.run('this file does not exist.rb', 'action_one')
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
