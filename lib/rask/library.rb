require 'rask/library_dsl'

module Rask

  class Library

    include LibraryDSL

    attr_reader :name

    def initialize(name, &block)
      @name = name
      @libraries = {}
      @actions = {
        libraries: :default,
        actions: :default
      }
      instance_eval &block
    end

    def libraries
      @libraries.each { |lib_name, lib| puts lib_name }
      @libraries
    end

    def actions
      @actions.each { |action_name, action| puts action_name }
      @actions
    end

  end

end
