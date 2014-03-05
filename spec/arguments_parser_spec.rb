require 'spec_helper'

require 'atelier/arguments_parser'

describe Atelier::ArgumentsParser do

  describe '#param' do
    before { subject.param(:param_name) }

    its(:arguments) { should include :param_name }
  end

  describe '#parse' do
    parameters = [:first_value, :second_value, :not_expected]
    before(:all) { @arguments_parser = Atelier::ArgumentsParser.new }

    subject { @arguments_parser.parse(*parameters) }
    before do
      @arguments_parser.param(:first_param)
      @arguments_parser.param(:second_param)
    end

    its(:first_param) { should == :first_value }
    its(:second_param) { should == :second_value }
  end

end
