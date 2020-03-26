require 'spec_helper'

require 'atelier/application'
require 'atelier/default_command'

describe Atelier::DefaultCommand do
  let(:application) { Atelier::Application.new }
  let(:super_command) { Atelier::Command.new(:super_command, application: application) }

  subject { described_class.new(:cmd_name, super_command: super_command) }

  describe '#initialize' do
    its(:name) { is_expected.to eq :cmd_name }
    its(:super_command) { is_expected.to eq super_command }
    its(:application) { is_expected.to eq application }
    # Very important:
    its(:defaults) { is_expected.to eq [] }

    it "require the super_command keyword arg" do
      expect {
        described_class.new(:cmd_name)
      }.to raise_error(ArgumentError, 'missing keyword: super_command')
    end

    its(:title) { is_expected.to eq nil }
    its(:description) { is_expected.to eq nil }
    its(:action) { is_expected.to eq nil }

    context 'with options' do
      subject {
        described_class.new(:cmd_name,
          application:   :application,
          super_command: :expected_command,
        )
      }

      it "prevent the defaults keyword arg" do
        expect {
          described_class.new(:cmd_name, super_command: super_command, defaults: ['help'])
        }.to raise_error(ArgumentError, 'unknown keyword: defaults')
      end

      its(:name) { is_expected.to eq :cmd_name }
      its(:super_command) { is_expected.to eq :expected_command }
      its(:application) { is_expected.to eq :application }
      its(:defaults) { is_expected.to eq [] }

      its(:title) { is_expected.to eq nil }
      its(:description) { is_expected.to eq nil }
      its(:action) { is_expected.to eq nil }
    end
  end
end
