
module Rask

  class Library

    attr_reader :name

    def initialize(name)
      @name = name
      @libraries = {}
    end

  end

end
