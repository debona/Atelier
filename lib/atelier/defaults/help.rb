require 'atelier/default_command'

module Atelier
  module Defaults
    module Help

      def self.factory(super_command)
        Atelier::DefaultCommand.new(:help, super_command: super_command) do |cmd|
          cmd.description = 'print this message'

          cmd.action do
            puts "#{super_command.name}: #{super_command.title}"

            puts "#{super_command.description}"

            switches = super_command.declared_switches
            puts 'Options:' if switches.any?
            switches.each do |switch|
              longs_n_shorts = switch.long + switch.short
              puts "\t#{longs_n_shorts.join(', ')}\n\t\t#{switch.desc.join("\n\t\t")}"
            end

            puts 'Default commands:'
            super_command.sub_commands.select { |sub_cmd| DefaultCommand === sub_cmd }.each do |sub_cmd|
              puts "  - #{super_command.name} #{sub_cmd.name}"
            end

            puts 'Commands:'
            super_command.sub_commands.reject { |sub_cmd| DefaultCommand === sub_cmd }.each do |sub_cmd|
              puts "  - #{super_command.name} #{sub_cmd.name}"
            end
          end
        end
      end

    end
  end
end
