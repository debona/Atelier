require 'spec_helper'

require 'atelier/globals'

describe Atelier::Globals do

  class GlobalClass
    include Atelier::Globals
  end

  describe '.application' do
    before(:all) do
      @global = GlobalClass.new
    end

    subject { @global }

    it 'returns every time the same application' do
      expect(subject.application).to eq subject.application
    end
  end

  describe '.command' do

    before(:all) do
      @global = GlobalClass.new
      @app = Atelier::Application.send(:new)
    end

    let(:root_command) { nil }
    let(:loading_command) { nil }

    before do
      allow(@global).to receive(:application) { @app }
      allow(@global.application.logger).to receive(:warn) { nil }
      @global.application.instance_eval { @root_command = root_command }
      allow(@global.application).to receive(:loading_command).and_return(loading_command)
    end

    context 'when NO other command is loading' do
      it 'redirects to the app load_root_command method' do
        expect(@global.application).to receive(:load_root_command).with(:name, {}).and_call_original
        @global.command(:name, {}) {}
      end

      it 'triggers the app run method' do
        if ARGV.any?
          expect(@global.application).to receive(:run).with(*ARGV)
        else
          expect(@global.application).to receive(:run).with(no_args)
        end
        @global.command(:name, {}) {}
      end
    end

    context 'when another command is loading' do
      let(:root_command) { Atelier::Command.new(:root) }
      let(:loading_command) { Atelier::Command.new(:loading) }

      it 'forwards the command call on the loading command' do
        expect(@global.application.loading_command).to receive(:command).with(:new_cmd, {})
        @global.command(:new_cmd, {}) {}
      end
    end

  end
end
