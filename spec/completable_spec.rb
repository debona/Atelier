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

        c.param(:remote, completion: ['github', 'gitlab'])
        c.params(:files)
        c.param(:branch, completion: ['master', 'staging'])

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
      subject(:complete) { command.complete(*args) }

      default_sub_commands = ["help", "completion", "complete"]
      all_files = Dir['*'] - ['.', '..']
      completing_file = all_files.first[0..-2]

      context "when the command declares nothing" do
        let(:command) do
          Atelier::Command.new(:cmd_name) do |c|
          end
        end

        context "when completing without args" do
          let(:args) { [] }

          it "includes all default sub_commands" do
            expect(complete).to include(*default_sub_commands)
          end

          it "includes all files" do
            expect(complete).to include(*all_files)
          end
        end

        context "when completing with: #{completing_file}" do
          let(:args) { [completing_file] }

          it "returns only the completing file" do
            expect(complete).to match_array(Dir["#{completing_file}*"])
          end
        end

        context "when completing with: first #{completing_file}" do
          let(:args) { ["first", completing_file] }

          it "returns only the completing file" do
            expect(complete).to match_array(Dir["#{completing_file}*"])
          end
        end
      end

      context "when the command declares sub_commands" do
        let(:command) do
          Atelier::Command.new(:cmd_name) do |c|
            c.command(:sub1) { }
            c.command(:sub2) { }
          end
        end

        let(:declared_sub_commands) { ["sub1", "sub2"] }

        context "when completing without args" do
          let(:args) { [] }

          it "includes all default sub_commands" do
            expect(complete).to include(*default_sub_commands)
          end

          it "includes the declared sub_commands" do
            expect(complete).to include(*declared_sub_commands)
          end
        end

        context "when completing with: sub" do
          let(:args) { ["sub"] }

          it "returns the filtered possibilities" do
            expect(complete).to match_array(declared_sub_commands)
          end
        end

        context "when completing with: sub1 another" do
          let(:sub1) { command.sub_commands_hash[:sub1] }

          let(:args) { ["sub1", "another"] }

          it 'delegates to the sub1 sub_command' do
            expect(sub1).to receive(:complete).with("another")
            complete
          end
        end

        context "when completing with: first sub" do
          let(:args) { ["first", "sub"] }

          it "does not include all default sub_commands" do
            expect(complete).not_to include(*default_sub_commands)
          end

          it "does not include the declared sub_commands" do
            expect(complete).not_to include(*declared_sub_commands)
          end
        end
      end

      context "when the command declares options" do
        let(:command) do
          Atelier::Command.new(:cmd_name) do |c|
            c.option(:completable, '-c', '--completable VALUE', 'description', completion: ["foo", "v1", "v2"])
            c.option(:option, '-o', '--option VALUE', 'description')
          end
        end

        let(:declared_option_switches) { ["-o", "--option", "-c", "--completable"] }

        context "when completing without args" do
          let(:args) { [] }

          it "does NOT include the declared sub_commands" do
            expect(complete).not_to include(*declared_option_switches)
          end
        end

        context "when completing with: -" do
          let(:args) { ["-"] }

          it "includes the declared sub_commands" do
            expect(complete).to include(*declared_option_switches)
          end
        end

        context "when completing with: --o" do
          let(:args) { ["--o"] }

          it "returns the filtered possibilities" do
            expect(complete).to eq(["--option"])
          end
        end

        context "when completing with: --option #{completing_file}" do
          let(:args) { ["--option", completing_file] }

          it "returns only the completing file" do
            expect(complete).to match_array(Dir["#{completing_file}*"])
          end
        end

        context "when completing with: --completable v" do
          let(:args) { ["--completable", "v"] }

          it "returns only the filtered option completion values" do
            expect(complete).to eq(["v1", "v2"])
          end
        end

        context "when completing with: stuff --completable v" do
          let(:args) { ["stuff", "--completable", "v"] }

          it "returns only the filtered option completion values" do
            expect(complete).to eq(["v1", "v2"])
          end
        end
      end

      context "when the command declares params" do
        let(:command) do
          Atelier::Command.new(:cmd_name) do |c|
            c.param(:remote, completion: ['github', 'gitlab'])
            c.param(:file)
            c.param(:branch, completion: ['master', 'staging'])
          end
        end

        context "when completing without args" do
          let(:args) { [] }

          it "includes all default sub_commands" do
            expect(complete).to include(*default_sub_commands)
          end

          it "includes all the first param completion" do
            expect(complete).to include('github', 'gitlab')
          end

          it "does not include the last param completion" do
            expect(complete).not_to include('master', 'staging')
          end

          it "does not include the files" do
            expect(complete).not_to include(*all_files)
          end
        end

        context "when completing with: gith" do
          let(:args) { ["gith"] }

          it "returns the filtered possibilities" do
            expect(complete).to eq(["github"])
          end
        end

        context "when completing with: github ''" do
          let(:args) { ["github", ""] }

          it "does not include all default sub_commands" do
            expect(complete).not_to include(*default_sub_commands)
          end

          it "does not include all the first param completion" do
            expect(complete).not_to include('github', 'gitlab')
          end

          it "does not include the last param completion" do
            expect(complete).not_to include('master', 'staging')
          end

          it "includes all the files" do
            expect(complete).to include(*all_files)
          end
        end

        context "when completing with: github middle ''" do
          let(:args) { ["github", "middle", ""] }

          it "does not include all default sub_commands" do
            expect(complete).not_to include(*default_sub_commands)
          end

          it "does not include all the first param completion" do
            expect(complete).not_to include('github', 'gitlab')
          end

          it "includes the last param completion" do
            expect(complete).to include('master', 'staging')
          end

          it "does not include the files" do
            expect(complete).not_to include(*all_files)
          end
        end
      end

      context "when the command declares everything possible" do
        let(:command) do
          Atelier::Command.new(:cmd_name) do |c|
            c.option(:completable, '-c', '--completable VALUE', 'description', completion: ["foo", "v1", "v2"])
            c.option(:option, '-o', '--option VALUE', 'description')

            c.param(:remote, completion: ['github', 'gitlab'])
            c.params(:files)
            c.param(:branch, completion: ['master', 'staging'])

            c.command(:sub1) { }
            c.command(:sub2) { }
          end
        end

        # TODO:
      end
    end
  end
end
