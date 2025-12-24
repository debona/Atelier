require 'spec_helper'

require 'atelier/argument_parser'

describe Atelier::ArgumentParser do

  describe '#param' do
    before { subject.param(:param_name) }

    its(:arguments) { is_expected.to include :param_name }
  end

  describe '#params' do
    before { subject.params(:params_name) }

    its(:arguments) { is_expected.to include :params_name }
  end

  describe '#parse' do
    let(:parameters) { [:one, :two, :three, :four, :five] }
    let(:argument_parser) { Atelier::ArgumentParser.new }
    subject { argument_parser.parse(parameters) }

    context 'for non-variable arguments' do
      before do
        argument_parser.param(:first_param)
        argument_parser.param(:second_param)
      end

      its([:first_param])  { is_expected.to eq :one }
      its([:second_param]) { is_expected.to eq :two }

      context 'when there are not enough values to parse' do
        let(:parameters) { [:one] }

        its([:first_param])  { is_expected.to eq :one }
        it 'omits the :second_param' do
          is_expected.to_not include(:second_param)
        end
      end
    end

    context 'for variable arguments' do
      before do
        argument_parser.param(:first_param)
        argument_parser.params(:var_params)
        argument_parser.param(:last_param)
      end

      its([:first_param]) { is_expected.to eq :one }
      its([:var_params])  { is_expected.to eq [:two, :three, :four] }
      its([:last_param])  { is_expected.to eq :five }
    end
  end

  describe "#param_completion_for" do
    let(:argument_parser) { Atelier::ArgumentParser.new }

    context 'for non-variable arguments' do
      let(:first_param_completion) { ["first_param_completion"] }
      let(:second_param_completion) { nil }
      let(:third_param_completion) { ["third_param_completion"] }

      before do
        argument_parser.param(:first_param, completion: first_param_completion)
        argument_parser.param(:second_param)
        argument_parser.param(:third_param, completion: third_param_completion)
      end

      it "returns the first param completion for index 0" do
        expect(argument_parser.param_completion_for(index: 0)).to eq(first_param_completion)
      end

      it "returns the second param completion for index 1" do
        expect(argument_parser.param_completion_for(index: 1)).to eq(second_param_completion)
      end

      it "returns the third param completion for index 2" do
        expect(argument_parser.param_completion_for(index: 2)).to eq(third_param_completion)
      end

      it "returns nil for index 3" do
        expect(argument_parser.param_completion_for(index: 3)).to eq(nil)
      end
    end

    context 'for variable arguments' do
      let(:first_param_completion) { ["first_param_completion"] }
      let(:var_params_completion) { ["var_params_completion"] }
      let(:last_param_completion) { ["last_param_completion"] }

      before do
        argument_parser.param(:first_param, completion: first_param_completion)
        argument_parser.params(:var_params, completion: var_params_completion)
        argument_parser.param(:last_param, completion: last_param_completion)
      end

      it "returns the first param completion for index 0" do
        expect(argument_parser.param_completion_for(index: 0)).to eq(first_param_completion)
      end

      it "returns the var params completion for index 1" do
        expect(argument_parser.param_completion_for(index: 1)).to eq(var_params_completion)
      end

      it "returns the var params completion for index 2" do
        expect(argument_parser.param_completion_for(index: 2)).to eq(var_params_completion)
      end

      it "returns the var params completion for index 3" do
        expect(argument_parser.param_completion_for(index: 3)).to eq(var_params_completion)
      end
    end
  end

end
