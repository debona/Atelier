
module Atelier
  module Default

    def load_default_commands

      command(:commands, default: true) do
        description 'print the sub-commands'

        action do
          cmd = super_command || self

          cmd.commands.each { |cmd_name, cmd| puts cmd_name }
        end
      end

      command(:help, default: true) do
        description 'print this message'

        action do
          cmd = super_command || self

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

      command(:completion, default: true) do
        action do |*args|
        end
      end

      command(:complete, default: true) do

        action do |*args|
        end
      end

    end
  end
end
