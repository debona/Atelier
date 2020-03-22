require 'spec_helper'

require 'atelier/optionable'

describe Atelier::Optionable do
  subject { Object.new.extend Atelier::Optionable }

  describe '#option' do
    it 'delegates the options parsing description' do
      opt_parser_args = [:a, :b, :c]
      expect(subject.option_parser).to receive(:on).with(*opt_parser_args)
      subject.option(:option_name, *opt_parser_args)
    end

    context 'with a completion block' do
      expected_proc = Proc.new { :very_expected_proc }
      switches = ['-a', '-b', '--long-a', '--long-b']

      before { subject.option(:option_name, *switches, &expected_proc) }

      describe 'its options_completions' do
        it { expect(subject.options_completions).to be_a Hash }

        switches.each do |switch|
          it { expect(subject.options_completions[switch]).to eq expected_proc }
        end
      end
    end
  end

  describe '#parse_options!' do
    context 'with declared options' do
      switch_name = '--first'
      option_name = :first

      before { subject.option(option_name, "#{switch_name} VALUE") }

      it 'forwards the message to option_parser' do
        params = ['arg1', 'arg2']
        expect(subject.option_parser).to receive(:parse).with(params)
        subject.send(:parse_options!, params)
      end

      context 'when parsing declared options' do
        let(:parse_options_return) { subject.send(:parse_options!, ['arg1', switch_name, 'expected_value', 'arg2']) }

        it { expect(parse_options_return).to match_array ['arg1', 'arg2'] }

        describe 'its options' do
          let(:options) {
            subject.send(:parse_options!, ['arg1', switch_name, 'expected_value', 'arg2'])
            subject.options
          }

          it { expect(options).to be_a Hash }
          it { expect(options[option_name]).to eq 'expected_value' }
        end
      end

      context 'when parsing undeclared options' do
        it 'raises an InvalidOption error' do
          expect { subject.send(:parse_options!, ['arg1', '--undeclared', 'arg2']) }.to raise_error(OptionParser::InvalidOption)
        end
      end
    end

    describe 'without declared options' do
      expected_parameters = [:first_param, '--invalid-option']

      it 'does NOT raise InvalidOption' do
        expect(subject.send(:parse_options!, expected_parameters)).to eq expected_parameters
      end
    end
  end

  describe '#declared_switches' do
    let(:optionable) do
      o = Object.new.extend Atelier::Optionable
      o.option(:alert, '-a', '--alert ALERT', 'Alert')
      o
    end

    subject { optionable.declared_switches }

    its(:size) { is_expected.to eq 1 }

    describe 'the defined switch' do
      subject { optionable.declared_switches.first }

      its(:short) { is_expected.to match_array ['-a'] }
      its(:long)  { is_expected.to match_array ['--alert'] }
    end
  end

  describe '#declared_switch_names' do
    let(:optionable) do
      o = Object.new.extend Atelier::Optionable
      o.option(:alert, '-a', '--alert ALERT', 'Alert')
      o
    end

    subject { optionable.declared_switch_names }

    it { is_expected.to match_array ['-a', '--alert'] }
  end
end
