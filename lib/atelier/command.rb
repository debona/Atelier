require 'ostruct'

require 'atelier/command_dsl'
require 'atelier/default_commands'
require 'atelier/arguments_parser'

module Atelier

  class Command

    include CommandDSL
    include ::Atelier::Default

    attr_reader :name, :commands
    attr_accessor :super_command

    def initialize(name, options = {}, &block)
      @name        = name
      @default     = options[:default]
      @title       = options[:title]       || ''
      @description = options[:description] || ''
      @commands    = options[:commands]    || {}
      @action      = options[:action]      || Proc.new {}


      @arguments_parser = options[:arguments_parser]

      load_default_commands unless default?
      instance_eval &block
    end

    def default?
      !! @default
    end

    def run(*parameters)
      if commands.key?(parameters.first)
        commands[parameters.first].run(*parameters[1..-1])
      elsif @arguments_parser
        arguments = parse_arguments(*parameters)
        instance_exec(arguments, &@action)
      else
        instance_exec(*parameters, &@action)
      end
    end

    private

    def parse_arguments(*parameters)
      @arguments_parser.parse(*parameters)
    end

  end

end