
module Atelier
  module Default

    def load_default_commands

      command(:commands, default: true) do |commands|
        commands.description = 'print the sub-commands'

        commands.action do
          cmd = commands.super_command || commands

          cmd.commands.each { |cmd_name, cmd| puts cmd_name }
        end
      end

      command(:help, default: true) do |help|
        help.description = 'print this message'

        help.action do
          cmd = help.super_command || help

          puts "#{cmd.name}: #{cmd.title}"
          puts "#{cmd.description}"
          puts ''

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

      command(:completion, default: true) do |completion|
        completion.description = 'Enable the completion with: eval "$(my_command.rb completion)"'

        completion.action do |*args|
          cmd = completion.super_command || completion

          executable_name = File.basename(ARGV[0] || '')

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

      command(:complete, default: true) do |complete|

        complete.action do |*args|
          cmd = complete.super_command || complete

          if args.size <= 1
            possibilities  = []
            possibilities += Dir['*']
            possibilities += Dir['.*']
            possibilities -= ['.', '..']
            possibilities += cmd.commands.keys
            pattern = /^#{Regexp.escape(args.first || '')}/
            puts possibilities.grep(pattern).join("\n")
          elsif cmd.commands.key?(args.first.to_sym)
            sub_command = args.first.to_sym
            cmd.run(sub_command, :complete, *args[1..-1]) if cmd.commands[sub_command].commands.key?(:complete)
          end
        end
      end

    end
  end
end
