require 'atelier/library_dsl'
require 'atelier/default_actions'

module Atelier

  class Command

    include CommandDSL
    include ::Atelier::Default

    attr_reader :name, :actions, :commands

    def initialize(name, &block)
      @name = name
      @title = ''
      @description = ''
      @commands = {}
      @actions = {}

      Default.constants.each do |constant|
        action = Default.const_get(constant)
        @actions[action.name] = action
      end

      instance_eval &block
    end

    def run(action_name, *parameters)
      action = actions[action_name]
      if action
        instance_exec(*parameters, &action.proc)
      elsif commands.key?(action_name)
        commands[action_name].run(*parameters)
      else
        raise "no action '#{action_name}'"
      end
    end

  end

end
