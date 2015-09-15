
module Atelier
  module Default

    def self.all
      {
        commands: commands,
        help: help,
        completion: completion,
        complete: complete
      }
    end

    def self.commands
      unless @commands
        @commands = ::Atelier::Command.new(:commands, default: true)
        @commands.description = 'print the sub-commands'
        @commands.action do
          cmd = @commands.super_command

          cmd.commands.each { |cmd_name, cmd| puts cmd_name }
        end
      end
      @commands
    end

    def self.help
      unless @help
        @help = ::Atelier::Command.new(:help, default: true)
        @help.description = 'print this message'

        @help.action do
          cmd = @help.super_command

          puts "#{cmd.name}: #{cmd.title}"
          puts ''
          puts cmd.description

          args = []
          cmd.arguments { |name, multiple| args << "<#{name}>#{multiple ? '*' : ''}" }
          puts ''
          puts "Usage : #{cmd.name} #{args.join(" ")}"

          unless args.empty?
            puts ''
            puts "Arguments:"
            cmd.arguments { |name, multiple, desc| puts "\t<#{name}>#{multiple ? '*' : ''}\n\t\t#{desc}" }
          end

          switches = cmd.available_switches # give the list of the custom switches
          unless switches.empty?
            puts ''
            puts 'Options:'
            switches.each do |switch|
              longs_n_shorts = switch.long + switch.short
              puts "\t#{longs_n_shorts.join(', ')}\n\t\t#{switch.desc.join("\n\t\t")}"
            end
          end

          puts ''
          puts 'Default commands:'
          cmd.commands.select.each do |command_name, command|
            puts "  - #{cmd.name} #{command_name}" if command.default?
          end

          puts ''
          puts 'Commands:'
          cmd.commands.each do |command_name, command|
            puts "  - #{cmd.name} #{command_name}" unless command.default?
          end
        end
      end
      @help
    end

    def self.completion
      unless @completion
        @completion = ::Atelier::Command.new(:completion, default: true)
        @completion.description = 'Enable the completion with: eval "$(my_command.rb completion)"'

        @completion.action do |*args|
          cmd = @completion.super_command

          executable_name = File.basename($PROGRAM_NAME)

          puts <<-EOS
            function __atelier_completion() {
              local cmd=$1
              shift
              $cmd complete "$@"
            }
            function __completion__handler() {
              COMPREPLY=( $( __atelier_completion "${COMP_WORDS[@]}" ) )
            }
            complete -o bashdefault -o default -F __completion__handler "#{executable_name}"
          EOS
        end
      end
      @completion
    end

    def self.complete
      unless @complete
        @complete = ::Atelier::Command.new(:complete, default: true)

        @complete.action do |*args|
          cmd = @complete.super_command

          if args.first && cmd.commands.key?(args.first.to_sym)
            sub_command = args.shift.to_sym
            cmd.run(sub_command, :complete, *args) if cmd.commands[sub_command].commands.key?(:complete)
            next # leave from the action block; `return` would leave the currently executed method
          end

          current = args.last || ''
          current_pattern = /^#{Regexp.escape(current)}/
          before = args[-2]
          possibilities  = []

          if matching_option_completion = cmd.options_completions[before]
            possibilities += matching_option_completion.call().grep(current_pattern)
          else
            possibilities += Dir[current + '*']
            possibilities -= ['.', '..']
            possibilities += cmd.commands.keys.grep(current_pattern) if args.size <= 1 # because the command can only be in first place
            possibilities += cmd.available_switche_names.grep(current_pattern)
          end

          puts possibilities.join("\n")
        end
      end
      @complete
    end

  end
end
