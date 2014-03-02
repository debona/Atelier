require 'spec_helper'

require 'atelier/arguments_parser'

describe Atelier::ArgumentsParser do

  describe '#param' do
    before { subject.param(:param_name) }

    its(:arguments) { should include :param_name }
  end

  describe '#parse' do
    parameters = [:expected_arg, :not_expected]
    before(:all) { @arguments_parser = Atelier::ArgumentsParser.new }

    subject { @arguments_parser.parse(*parameters) }
    before { @arguments_parser.param(:param_name) }

    its(:param_name) { should == :expected_arg }
  end

end
