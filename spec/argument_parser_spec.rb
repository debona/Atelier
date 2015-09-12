require 'spec_helper'

require 'atelier/argument_parser'

describe Atelier::ArgumentParser do

  before(:all) do
    @arg_parser = Atelier::ArgumentParser.new
    @arg_parser.param(:param_name, 'expected_desc')
    @arg_parser.params(:params_name, 'params_expected_desc')
  end

  describe '#param' do
    subject { @arg_parser }

    its(:arguments) { should include :param_name }

    context 'with description' do
      subject { @arg_parser.arguments_descs }

      its([:param_name]) { should == 'expected_desc' }
    end
  end

  describe '#params' do
    subject { @arg_parser }

    its(:arguments) { should include :params_name }

    context 'with description' do
      subject { @arg_parser.arguments_descs }

      its([:params_name]) { should == 'params_expected_desc' }
    end
  end

  describe '#parse' do
    parameters = [:one, :two, :three, :four, :five]
    let(:argument_parser) { Atelier::ArgumentParser.new }
    subject { argument_parser.parse(parameters) }

    context 'for non-variable arguments' do
      before do
        argument_parser.param(:first_param)
        argument_parser.param(:second_param)
      end

      its([:first_param])  { should == :one }
      its([:second_param]) { should == :two }
    end

    context 'for variable arguments' do
      before do
        argument_parser.param(:first_param)
        argument_parser.params(:var_params)
        argument_parser.param(:last_param)
      end

      its([:first_param]) { should == :one }
      its([:var_params])  { should == [:two, :three, :four] }
      its([:last_param])  { should == :five }

    end
  end

end
