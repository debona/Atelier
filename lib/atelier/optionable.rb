require 'optparse'

module Atelier
  module Optionable

    def option_parser
      @option_parser ||= OptionParser.new
    end

    def options_completions
      @options_completions ||= {}
    end

    def options
      @options ||= {}
    end


    def option(name, *opt_parser_args, &completion_block)
      switches_before = Array.new(option_parser.top.list)
      option_parser.on(*opt_parser_args) do |o|
        options[name] = o
      end
      return unless block_given?

      new_switch = (option_parser.top.list - switches_before).first

      longs_and_shorts = (new_switch.long + new_switch.short).flatten
      longs_and_shorts.each { |name| options_completions[name] = completion_block }
    end


    def available_switches
      switches = option_parser.top.list # give the list of the custom switches
      Array.new(switches)
    end

    def available_switche_names
      names = available_switches.collect { |switch| [switch.long, switch.short] }
      names.flatten
    end

    def parse_options!(parameters)
      if available_switches.any?
        option_parser.parse(parameters)
      else
        parameters
      end
    end
  end
end

