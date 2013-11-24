
module Rask

  class Library

    attr_reader :name

    def initialize(name)
      @name = name
      @libraries = {}
    end

    def libraries
      @libraries.each { |key, value| puts key }
      @libraries
    end

  end

end
