require 'spec_helper'

require 'atelier/arguments_parser'

describe Atelier::ArgumentsParser do

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
    let(:arguments_parser) { Atelier::ArgumentsParser.new }
    subject { arguments_parser.parse(*parameters) }

    context 'for non-variable arguments' do
      before do
        arguments_parser.param(:first_param)
        arguments_parser.param(:second_param)
      end

      its(:first_param)  { should == :one }
      its(:second_param) { should == :two }
    end

    context 'for variable arguments' do
      before do
        arguments_parser.param(:first_param)
        arguments_parser.params(:var_params)
        arguments_parser.param(:last_param)
      end

      its(:first_param) { should == :one }
      its(:var_params)  { should == [:two, :three, :four] }
      its(:last_param)  { should == :five }

    end
  end

end
