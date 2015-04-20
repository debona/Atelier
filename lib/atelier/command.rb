require 'ostruct'

require 'atelier/command_dsl'
require 'atelier/default_commands'
require 'atelier/arguments_parser'

module Atelier

  class Command

    include CommandDSL

    attr_reader :name, :commands
    attr_accessor :title, :description, :super_command

    def initialize(name, options = {}, &block)
      @name          = name
      @super_command = options[:super_command]
      @default       = options[:default]     || false
      @title         = options[:title]       || ''
      @description   = options[:description] || ''
      @action        = options[:action]      || Proc.new {}

      @commands = default? ? {} : ::Atelier::Default.all
      @commands.merge!(options[:commands]) if options[:commands]

      @arguments_parser = options[:arguments_parser]

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
        command.run(*parameters)
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
