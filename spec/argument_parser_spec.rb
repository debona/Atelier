require 'spec_helper'

require 'atelier/argument_parser'

describe Atelier::ArgumentParser do

  describe '#param' do
    before { subject.param(:param_name) }

    its(:arguments) { should include :param_name }
  end

  describe '#params' do
    before { subject.params(:params_name) }

    its(:arguments) { should include :params_name }
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
