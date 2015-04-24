require 'spec_helper'

require 'atelier/globals'

describe Atelier::Globals do

  class GlobalClass
    include Atelier::Globals

    attr_accessor :application
  end

  before(:all) do
    @global = GlobalClass.new
    @global.application = Atelier::Application.send(:new)
  end

  let(:root_command) { nil }
  let(:loading_command) { nil }

  before do
    @global.application.logger.stub(:warn) { nil }
    @global.application.instance_eval { @root_command = root_command }
    @global.application.stub(:loading_command) { loading_command }
  end

  describe '.command' do

    context 'when NO other command is loading' do
      it 'should redirect to the app load_root_command method' do
        @global.application.should_receive(:load_root_command).with(:name, {}).and_call_original
        @global.command(:name, {}) {}
      end

      it 'should trigger the app run method' do
        @global.application.should_receive(:run).with(*ARGV)
        @global.command(:name, {}) {}
      end
    end

    context 'when another command is loading' do
      let(:root_command) { Atelier::Command.new(:root) }
      let(:loading_command) { Atelier::Command.new(:loading) }

      it 'should forward the command call on the loading command' do
        @global.application.loading_command.should_receive(:command).with(:new_cmd, {})
        @global.command(:new_cmd, {}) {}
      end
    end

  end
end
