
module Rask

  class Library

    attr_reader :name

    def initialize(name)
      @name = name
      @libraries = {}
      @actions = {
        libraries: :default,
        actions: :default
      }
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
