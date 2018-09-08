require 'spec_helper'

require 'atelier/parameterable'

describe Atelier::Parameterable do
  subject { Object.new.extend Atelier::Parameterable }

  describe '#param' do
    it 'delegates the arguments parsing description' do
      expect(subject.argument_parser).to receive(:param).with(:param_name)
      subject.param(:param_name)
    end
  end

  describe '#params' do
    it 'delegates the arguments parsing description' do
      expect(subject.argument_parser).to receive(:params).with(:param_name)
      subject.params(:param_name)
    end
  end

  describe '#parse_parameters' do
    it 'forwards the message to argument_parser' do
      expect(subject.argument_parser).to receive(:parse).with('arg1', 'arg2')
      subject.send(:parse_parameters, 'arg1', 'arg2')
    end
  end
end
