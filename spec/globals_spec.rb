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
        it 'should redirect to the app load_root_command method' do
          command(:previous, {}) {}
          @app.logger.should_receive(:warn)
          command(:name, {}) {}
        end
      end
    end

    context 'when another command is loading' do

      before(:all) do
        @root = nil
        @loading = nil
        @new_cmd = nil

        command(:root, {}) do |root|
          @root = root
          command(:loading, {}) do |loading|
            @loading = loading
            command(:new_cmd, {}) do |new_cmd|
              @new_cmd = new_cmd
            end
          end
        end
      end

      describe 'the loading command' do
        subject { @loading }

        its(:commands) { should include(:new_cmd) }
      end

      describe 'the new command super_command' do
        subject { @new_cmd.super_command }

        its(:name) { should == :loading }
      end

    end

  end
end
