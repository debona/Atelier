require 'spec_helper'

require 'atelier/command'
require 'atelier/completable'

describe Atelier::Completable do

  describe '.complete_files' do
    it 'returns files matching the pattern' do
      files = Atelier::Completable.complete_files('spec/completable')
      expect(files).to include('spec/completable_spec.rb')
    end

    it 'excludes . and ..' do
      files = Atelier::Completable.complete_files('')
      expect(files).not_to include('.', '..')
    end
  end

  describe 'included in a class' do
    let(:command) do
      Atelier::Command.new(:cmd_name) do |c|
        c.option(:option, '-o', '--option OPT', 'test purpose option', completion: -> { ["value1", "value2"] })
        c.option(:alert, '-a', '--alert ALERT', 'test purpose option')
        c.command :sub_command do |s|
          s.command :sub_sub_command do
          end
        end
      end
    end

    describe '#completable?' do
      it 'returns true' do
        expect(command.completable?).to eq true
      end
    end

    describe '#complete' do
      subject { command.complete(*args) }

      context 'without any args' do
        let(:args) { [] }

        it 'includes sub command names' do
          expect(subject).to include(:sub_command)
        end

        it 'includes switch names' do
          expect(subject).to include('-o', '--option', '-a', '--alert')
        end

        it 'includes files' do
          files = Dir['*'] - ['.', '..']
          expect(subject).to include(*files)
        end
      end

      context 'with a partial match' do
        let(:args) { ['su'] }

        it 'filters sub commands by prefix' do
          expect(subject).to include(:sub_command)
        end
      end

      context 'with an option that has completion' do
        let(:args) { ['--option', 'val'] }

        it 'delegates to the option completion proc' do
          expect(subject).to eq ['value1', 'value2']
        end

        it 'filters by the current value' do
          results = command.complete('--option', 'value1')
          expect(results).to eq ['value1']
        end
      end

      context 'when the first arg match a sub_command' do
        let(:args) { ['sub_command', 'sub'] }

        it 'delegates to the sub command' do
          expect(command.sub_commands_hash[:sub_command]).to receive(:complete).with('sub')
          command.complete(*args)
        end

        it 'returns the sub command completion results' do
          results = command.complete('sub_command', 'sub_sub')
          expect(results).to include(:sub_sub_command)
        end

        context 'when sub command is not completable' do
          before do
            sub_cmd = command.sub_commands_hash[:sub_command]
            allow(sub_cmd).to receive(:completable?).and_return(false)
          end

          let(:args) { ['sub_command', 'test'] }

          it 'does not delegate to the sub command' do
            expect(command.sub_commands_hash[:sub_command]).not_to receive(:complete)
            command.complete(*args)
          end
        end
      end

      context 'with more than one arg' do
        let(:args) { ['first', '-'] }

        it 'does not include sub commands in results' do
          expect(subject).not_to include(:sub_command)
        end

        it 'includes switches that match the prefix' do
          expect(subject).to include('-o', '-a', '--alert', '--option')
        end
      end
    end
  end
end
