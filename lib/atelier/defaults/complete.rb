require 'atelier/default_command'

module Atelier
  module Defaults
    module Complete

      def self.factory(super_command)
        Atelier::DefaultCommand.new(:complete, super_command: super_command) do |cmd|
          cmd.title = ''
          cmd.description = 'complete command line args'

          cmd.action do |*args|
            if args.first && super_command.sub_command_names.include?(args.first.to_sym)
              sub_command = args.shift.to_sym
              super_command.run(sub_command, :complete, *args) if super_command.sub_commands_hash[sub_command].sub_command_names.include?(:complete)
              next # leave from the action block; `return` would leave the currently executed method
            end

            current = args.last || ''
            current_pattern = /^#{Regexp.escape(current)}/
            before = args[-2]
            possibilities  = []

            if matching_option_completion = super_command.options_completions[before]
              possibilities += matching_option_completion.call().grep(current_pattern)
            else
              possibilities += Dir[current + '*']
              possibilities -= ['.', '..']
              possibilities += super_command.sub_command_names.grep(current_pattern) if args.size <= 1 # because the command can only be in first place
              possibilities += super_command.declared_switch_names.grep(current_pattern)
            end

            puts possibilities.join("\n")
          end
        end
      end

    end
  end
end
