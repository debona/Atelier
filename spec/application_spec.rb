require 'spec_helper'

require 'atelier/application'

describe Atelier::Application do
  before(:all) { @app = Atelier::Application.instance }
  subject { @app }

  describe '.instance' do
    its(:root_library) { should be_nil }
    its(:logger) { should be_a Logger }

    describe 'its side-effects' do
      it 'Kernel methods should include :library' do
        Kernel.methods.should include :library
      end

      it 'library should redirect to the app load_root_library method' do
        @app.should_receive(:load_root_library).with(:name)
        Kernel.library(:name) {}
      end
    end
  end

  describe '#load_root_library' do
    name = :lib_name

    before(:all) { @app.load_root_library(name) {} }
    subject { @app.root_library }

    it { should be_a Atelier::Library }
    its(:name) { should == name }
  end

  describe '#send_action' do
    context 'with an existing action' do
      action_name     = :action_name
      parameter       = :param
      expected_result = [parameter]

      before  { @app.root_library.stub(action_name) { |*params| params } }
      subject { @app.send_action(action_name.to_s, parameter) }

      it { should be_a Array }
      it { should == expected_result }
    end

    context 'with wrong action' do
      it 'should display an error' do
        @app.logger.should_receive(:error)
        @app.send_action('wrong_action', 'param1', 'param2')
      end
    end
  end

  describe '#run' do
    context 'with an existing library file' do
      subject { @app }

      it 'should load the library file as root library' do
        subject.run('spec/fixtures/sample.rb', :sample_action)
        subject.root_library.name.should == :sample
      end
      it 'should send_action with the :sample_action action' do
        subject.should_receive(:send_action).with(:sample_action)
        subject.run('spec/fixtures/sample.rb', :sample_action)
      end
    end

    context 'with wrong library' do
      it 'should display an error' do
        @app.logger.should_receive(:error)
        @app.run('this file does not exist.rb', 'action_one')
      end
    end
  end

  describe '#locate_library' do
    subject { @app.locate_library(file_name) }

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
