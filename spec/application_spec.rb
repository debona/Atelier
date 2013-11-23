require 'rask/application'

describe Rask::Application do
  before(:all) { @app = Rask::Application.instance }
  subject { @app }

  describe '#instance' do
    its(:library) { should be_nil }
    its(:logger) { should be_a Logger }

    describe 'its side-effects' do
      it 'Kernel methods should include :library' do
        Kernel.methods.should include :library
      end

      it 'library should redirect to the app load_library method' do
        @app.should_receive(:load_library).with(:name)
        Kernel.library(:name) {}
      end
    end
  end

  describe '#load_library' do
    name = :lib_name

    before(:all) { @app.load_library(name) {} }
    subject { @app.library }

    it { should be_a Rask::Library }
    its(:name) { should == name }
  end

  describe '#send_action' do
    context 'with an existing action' do
      action_name     = :action_name
      parameter       = :param
      expected_result = [parameter]

      before  { @app.library.stub(action_name) { |*params| params } }
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

      it 'should load the library file' do
        subject.run('spec/fixtures/sample.rb', :sample_action)
        subject.library.name.should == :sample
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

end