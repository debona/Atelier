require 'atelier/command_dsl'
require 'atelier/default_commands'

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

      load_default_commands unless default?
      instance_eval &block
    end

    def default?
      !! @default
    end

    def run(*parameters)
      if commands.key?(parameters.first)
        commands[parameters.first].run(*parameters[1..-1])
      else
        instance_exec(*parameters, &@action)
      end
    end

  end

end
