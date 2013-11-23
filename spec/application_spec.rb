require 'rask/application'

describe Rask::Application do

  describe '#instance' do
    subject { Rask::Application.instance }

    its(:library) { should be_nil }
    its(:logger) { should be_a Logger }
  end

  describe '#load' do
    name = :lib_name

    before(:all) do
      @app = Rask::Application.instance
      @app.load(name) {}
    end

    subject { @app.library }

    it { should be_a Rask::Library }
    its(:name) { should == name }
  end

  describe '#run' do
    context 'with an existing action' do
      action_name     = :action_name
      parameter       = :param
      expected_result = [parameter]

      before(:all) do
        @app = Rask::Application.instance
      end
      subject do
        @app.library.stub(action_name) { |*params| params }
        @app.run(action_name.to_s, parameter)
      end

      it { should be_a Array }
      it { should == expected_result }
    end

    context 'with wrong action' do
      it 'should display an error' do
        app = Rask::Application.instance
        app.logger.should_receive(:error)
        app.run('wrong action', 'param1', 'param2')
      end
    end
  end

end