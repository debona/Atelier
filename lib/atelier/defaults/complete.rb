require 'atelier/default_command'

module Atelier
  module Defaults
    module Complete

      def self.factory(super_command)
        Atelier::DefaultCommand.new(:complete, super_command: super_command) do |cmd|
          cmd.title = ''
          cmd.description = 'complete command line args'

          cmd.action do |*args|
            possibilities = super_command.complete(*args)
            puts possibilities.join("\n") if possibilities
          end
        end
      end

    end
  end
end
