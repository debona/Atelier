require 'rask/library'

module Rask

  class Application

    attr_reader :libraries

    def initialize
      @libraries = {}
    end

    def load(name, &block)
      @libraries[name] = Library.new(name, &block)
    end

    def run(*parameters)
      @libraries.first.last.send(*parameters)
    end

  end

end
