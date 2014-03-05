require 'ostruct'

module Atelier

  class ArgumentsParser

    def initialize
      @arguments_range = {}
    end

    def arguments
      @arguments_range.keys
    end

    def param(name)
      @arguments_range[name] = 0

      @arguments_range.each do |name, arity|
        @arguments_range[name] = Range.new(arity.begin, arity.end - 1) if arity.is_a? Range
      end
    end

    def params(name)
      @arguments_range[name] = 0..-1
    end

    def parse(*parameters)
      parsed = {}

      @arguments_range.each do |name, arity|
        parsed[name] = parameters.slice!(arity)
      end

      OpenStruct.new(parsed)
    end

  end

end
