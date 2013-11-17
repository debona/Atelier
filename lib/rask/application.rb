require 'rask/library'

module Rask

  class Application

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
