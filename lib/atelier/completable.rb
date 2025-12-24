module Atelier
  module Completable

    def self.complete_files(file)
      Dir[file + '*'] - ['.', '..']
    end

    def completable?
      true
    end

    def complete(*args)
      first = args.first
      penultimate = args[-2]
      completing = args.last || ''

      # If the first args is perfectly matching a subcommand, delegate to this subcommand
      sub_command = sub_commands_hash[first&.to_sym]
      if sub_command&.completable?
        args.shift
        return sub_command.complete(*args)
      end

      # If the completing arg begin with a "-", complete with options & switches
      return declared_switch_names.select { |s| s.start_with?(completing) } if completing.start_with?("-")

      # If the penultimate args is matching an option, delegate to this option
      return complete_option(penultimate, completing) if completable_option?(penultimate)

      # Remove options from args
      param_args = remove_option(args)
      if completing != (param_args.last || '') # The completing arg looks to be an option value
        # At this point, options have been handled, and option values with a declared completion too
        # So if the parser estimate the completing arg is an option value, let's complete with the default
        return Atelier::Completable.complete_files(completing)
      end

      # Otherwise, the completing arg is a param or maybe a subcommand
      possibilities  = []
      possibilities += sub_command_names.select { |s| s.start_with?(completing) } if args.size <= 1 # because the command can only be in first place

      completing_index = param_args.empty? ? 0 : param_args.size - 1
      if completable_param?(completing_index)
        possibilities += complete_param(completing_index, completing)
      else
        possibilities += Atelier::Completable.complete_files(completing)
      end

      possibilities.map(&:to_s)
    end

    def completable_option?(opt_name)
      !!options_completions[opt_name]
    end

    def complete_option(opt_name, completing)
      completion = options_completions[opt_name]
      possibilities =
        if completion.is_a?(Array)
          completion.dup
        else
          completion.call()
        end

      possibilities.select { |s| s.start_with?(completing) }
    end

    def remove_option(args)
      parse_options!(args)
    rescue OptionParser::ParseError
      # Simply remove switches, ignoring option values...
      # So at this point, the completion is partially broken
      args.reject { |s| s.start_with('-') }
    end

    def completable_param?(index)
      argument_parser.param_completion_for(index:)
    end

    def complete_param(index, completing)
      completion = argument_parser.param_completion_for(index:)
      possibilities =
        if completion.is_a?(Array)
          completion.dup
        else
          completion.call()
        end

      possibilities.select { |s| s.start_with?(completing) }
    end
  end
end
