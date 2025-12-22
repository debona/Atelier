
module Atelier
  module Completable

    def complete(*args)
      first = args.first
      penultimate = args[-2]
      last = args.last || ''

      # If the first args is perfectly matching a subcommand, delegate to this subcommand
      sub_command = sub_commands_hash[first&.to_sym]
      if sub_command && sub_command.sub_command_names.include?(:complete)
        args.shift
        return sub_command.complete(*args)
      end

      # If the penultimate args is matching an option, delegate to this option
      option_completion = options_completions[penultimate]
      if option_completion
        return option_completion.call().select { |s| s.start_with?(last) }
      end

      # Otherwise, cumulate the different possibilities
      possibilities  = []
      possibilities += sub_command_names.select { |s| s.start_with?(last) } if args.size <= 1 # because the command can only be in first place
      possibilities += declared_switch_names.select { |s| s.start_with?(last) }

      possibilities += Dir[last + '*'] - ['.', '..']

      possibilities
    end

  end
end
