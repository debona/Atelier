require 'spec_helper'

require 'atelier/globals'

describe :Globals do

  class GlobalClass
    include Atelier::Globals
  end

  before(:all) do
    @global = GlobalClass.new
    @app = Atelier::Application.instance
  end

  describe '.command' do

    context 'when NO other command is loading' do
      it 'should redirect to the app load_root_command method' do
        @app.should_receive(:load_root_command).with(:name, {})
        @global.command(:name, {}) {}
      end

      it 'should trigger the app run method' do
        @app.should_receive(:run).with(*ARGV)
        @global.command(:name, {}) {}
      end

      context 'when root_command is already defined' do
        it 'should log a warning' do
          @global.command(:previous, {}) {}
          @app.logger.should_receive(:warn)
          @global.command(:name, {}) {}
        end

        it 'should override the root command' do
          @global.command(:previous, {}) {}
          @global.command(:override, {}) {}
          @app.root_command.name.should == :override
        end
      end
    end

    context 'when another command is loading' do
      it 'should forward the command call on the loading command' do
        @global.command(:root, {}) do |root|
          @global.command(:loading, {}) do |loading|
            loading.should_receive(:command).with(:new_cmd, {})
            @global.command(:new_cmd, {}) {}
          end
        end
      end
    end

  end
end
