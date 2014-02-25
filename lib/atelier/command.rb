require 'atelier/command_dsl'
require 'atelier/default_actions'

module Atelier

  class Command

    include CommandDSL
    include ::Atelier::Default

    attr_reader :name, :commands

    def initialize(name, &block)
      @name = name
      @title = ''
      @description = ''
      @commands = {}
      @action = Proc.new {}

      Default.constants.each do |constant|
        action = Default.const_get(constant)
        @actions[action.name] = action
      end

      instance_eval &block
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
