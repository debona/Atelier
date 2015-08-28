
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

          puts "#{cmd.description}"

          switches = cmd.option_parser.top.list # give the list of the custom switches
          unless switches.empty?
            puts 'Options:'
            switches.each do |switch|
              longs_n_shorts = switch.long + switch.short
              puts "\t#{longs_n_shorts.join(', ')}\n\t\t#{switch.desc.join("\n\t\t")}"
            end
          end

          puts 'Default commands:'
          cmd.commands.select.each do |command_name, command|
            puts "  - #{cmd.name} #{command_name}" if command.default?
          end

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

          current = args.last || ''

          if args.first && cmd.commands.key?(args.first.to_sym)
            sub_command = args.shift.to_sym
            cmd.run(sub_command, :complete, *args) if cmd.commands[sub_command].commands.key?(:complete)
          else
            pattern = /^#{Regexp.escape(current)}/
            possibilities  = []
            possibilities += Dir[current + '*']
            possibilities -= ['.', '..']
            possibilities += cmd.commands.keys.grep(pattern) if args.size <= 1 # because the command can only be in first place
            puts possibilities.join("\n")
          end
        end
      end
      @complete
    end

  end
end
