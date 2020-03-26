require 'atelier/default_command'

module Atelier
  module Defaults
    module Commands

      def self.factory(super_command)
        Atelier::DefaultCommand.new(:commands, super_command: super_command) do |cmd|
          cmd.title = ''
          cmd.description = 'print the sub-commands'

          cmd.action do
            cmd.super_command.sub_command_names.map do |cmd_name|
              puts cmd_name
              cmd_name
            end
          end
        end
      end

    end
  end
end
