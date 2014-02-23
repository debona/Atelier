require 'atelier/library_dsl'
require 'atelier/default_actions'

module Atelier

  class Library

    include LibraryDSL
    include ::Atelier::Default

    attr_reader :name

    def initialize(name, &block)
      @name = name
      @title = ''
      @description = ''
      @libraries = {}
      @actions = {}
      Default.instance_methods.each do |action_name|
        @actions[action_name] = :default
      end

      instance_eval &block
    end

    def run(action_name, *parameters)
      action = @actions[action_name]
      if action
        instance_exec(*parameters, &action.proc)
      elsif @libraries.key?(action_name)
        @libraries[action_name].run(*parameters)
      else
        raise "no action '#{action_name}'"
      end
    end

  end

end
