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
    context "when there are NO declared_params" do
      it "does NOT forward the message to argument_parser" do
        expect(subject.argument_parser).to_not receive(:parse)
        subject.parse_parameters(['arg1', 'arg2'])
      end

      it "returns the raw args without any change" do
        expect(subject.parse_parameters(:raw_args)).to eq :raw_args
      end
    end

    context "when there are declared_params" do
      it "forwards the message to argument_parser" do
        subject.param(:param1)
        subject.param(:param2)
        expect(subject.argument_parser).to receive(:parse).with(['arg1', 'arg2'])
        subject.parse_parameters(['arg1', 'arg2'])
      end

      it "returns a hash with the parsed parameters" do
        subject.param(:param1)
        subject.param(:param2)
        expect(subject.parse_parameters(['arg1', 'arg2'])).to eq({ param1: 'arg1', param2: 'arg2' })
      end
    end
  end
end
