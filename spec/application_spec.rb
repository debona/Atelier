require 'rask/application'

describe Rask::Application do

  describe '#instance' do
    subject { Rask::Application.instance }

    its(:libraries) { should == {} }
  end

  describe '#load' do
    name = :lib_name

    before(:all) do
      @app = Rask::Application.instance
      @app.load(name) {}
    end
    subject { @app }

    its(:libraries) { should have(1).item }
    its(:libraries) { should include ( name ) }

    describe 'loaded library' do
      subject { @app.libraries[name] }

      it { should be_a Rask::Library }
    end

  end

  describe '#run' do
    action_name     = :action_name
    parameter       = :param
    expected_result = [parameter]

    before(:all) do
      @app = Rask::Application.instance
      @app.load(:lib_name) { action(action_name) { |*params| params } }
    end
    subject { @app.run(action_name.to_s, parameter) }

    it { should be_a Array }
    it { should == expected_result }

    # TODO : should display a clear message on stderr if the lib and/or action does not exist
  end

end