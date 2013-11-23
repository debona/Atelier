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

  describe '#run' do
    context 'with an existing action' do
      action_name     = :action_name
      parameter       = :param
      expected_result = [parameter]

      subject do
        @app.library.stub(action_name) { |*params| params }
        @app.run(action_name.to_s, parameter)
      end

      it { should be_a Array }
      it { should == expected_result }
    end

    context 'with wrong action' do
      it 'should display an error' do
        @app.logger.should_receive(:error)
        @app.run('wrong action', 'param1', 'param2')
      end
    end
  end

end