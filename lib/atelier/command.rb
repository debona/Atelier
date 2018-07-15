require 'atelier/command_dsl'
require 'atelier/default_commands'
require 'atelier/argument_parser'
require 'optparse'

module Atelier
  class Command
    include CommandDSL

    attr_reader :name, :commands, :options, :argument_parser, :options_completions
    attr_accessor :title, :description, :super_command, :option_parser

    def initialize(name, **options, &block)
      @name          = name
      @super_command = options[:super_command]
      @default       = options[:default]     || false
      @title         = options[:title]       || ''
      @description   = options[:description] || ''
      @action        = options[:action]      || Proc.new {}

      @commands = default? ? {} : ::Atelier::Default.all
      @commands.merge!(options[:commands]) if options[:commands]

      @argument_parser = options[:argument_parser]

      @option_parser   = options[:option_parser] || OptionParser.new
      @options_completions = {}
      @options = {}

      @loading = block_given?
      load(&block) if block_given?
    end

    def loading?
      !!@loading
    end

    def load
      @loading = true
      yield(self)
      @loading = false
    end

    def default?
      !!@default
    end

    def run(*parameters)
      if parameters.first && commands.key?(parameters.first.to_sym)
        cmd_name = parameters.shift.to_sym
        command = commands[cmd_name]
        command.super_command = self # useful for default commands
        return command.run(*parameters)
      elsif @argument_parser
        parameters = parse_options!(parameters)
        arguments = parse_arguments(parameters)
        @action.call(arguments)
      else
        parameters = parse_options!(parameters)
        @action.call(*parameters)
      end
    end

    def available_switches
      switches = @option_parser.top.list # give the list of the custom switches
      Array.new(switches)
    end

    def available_switche_names
      names = available_switches.collect { |switch| [switch.long, switch.short] }
      names.flatten
    end

    private

    def parse_options!(parameters)
      if !available_switches.empty?
        @option_parser.parse(parameters)
      else
        parameters
      end
    end

    def parse_arguments(*parameters)
      @argument_parser.parse(*parameters)
    end
  end
end
