require 'atelier/library_dsl'
require 'atelier/default_actions'

module Atelier

  class Library

    include LibraryDSL
    include ::Atelier::Default

    attr_reader :name, :actions, :libraries

    def initialize(name, &block)
      @name = name
      @title = ''
      @description = ''
      @libraries = {}
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
      elsif libraries.key?(action_name)
        libraries[action_name].run(*parameters)
      else
        raise "no action '#{action_name}'"
      end
    end

  end

end
