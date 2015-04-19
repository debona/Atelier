require 'spec_helper'

require 'atelier/globals'

describe :Globals do

  before(:all) { @app = Atelier::Application.instance }

  describe '.command' do

    context 'when NO other command is loading' do
      it 'should redirect to the app load_root_command method' do
        @app.should_receive(:load_root_command).with(:name, {})
        command(:name, {}) {}
      end

      it 'should trigger the app run method' do
        @app.should_receive(:run).with(*ARGV)
        command(:name, {}) {}
      end

      context 'when root_command is already defined' do
        it 'should log a warning' do
          command(:previous, {}) {}
          @app.logger.should_receive(:warn)
          command(:name, {}) {}
        end

        it 'should override the root command' do
          command(:previous, {}) {}
          command(:override, {}) {}
          @app.root_command.name.should == :override
        end
      end
    end

    context 'when another command is loading' do
      it 'should forward the command call on the loading command' do
        command(:root, {}) do |root|
          command(:loading, {}) do |loading|
            loading.should_receive(:command).with(:new_cmd, {})
            command(:new_cmd, {}) {}
          end
        end
      end
    end

  end
end
