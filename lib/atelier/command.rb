require 'ostruct'

require 'atelier/command_dsl'
require 'atelier/default_commands'
require 'atelier/arguments_parser'

module Atelier

  class Command

    include CommandDSL
    include ::Atelier::Default

    attr_reader :name, :commands, :super_command

    def initialize(name, options = {})
      @name          = name
      @super_command = options[:super_command]
      @default       = options[:default]
      @title         = options[:title]       || ''
      @description   = options[:description] || ''
      @commands      = options[:commands]    || {}
      @action        = options[:action]      || Proc.new {}

      @arguments_parser = options[:arguments_parser]

      load_default_commands unless default?

      yield(self) if block_given?
    end

    def default?
      !! @default
    end

    def run(*parameters)
      if parameters.first && commands.key?(parameters.first.to_sym)
        commands[parameters.first.to_sym].run(*parameters[1..-1])
      elsif @arguments_parser
        arguments = parse_arguments(*parameters)
        @action.call(arguments)
      else
        @action.call(*parameters)
      end
    end

    private

    def parse_arguments(*parameters)
      @arguments_parser.parse(*parameters)
    end

  end

end
