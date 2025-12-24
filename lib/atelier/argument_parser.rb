module Atelier
  class ArgumentParser

    def initialize
      @arguments_range = {}
      @completions = {}
    end

    def declared_params
      @arguments_range.keys
    end

    def arguments
      @arguments_range.keys
    end

    def param(name, completion: nil)
      @arguments_range[name] = 0
      @completions[name] = completion

      @arguments_range.each do |name, arity|
        @arguments_range[name] = Range.new(arity.begin, arity.end - 1) if arity.is_a? Range
      end
    end

    def params(name, completion: nil)
      @arguments_range[name] = 0..-1
      @completions[name] = completion
    end

    def parse(parameters)
      parameters = parameters.dup
      parsed = {}

      @arguments_range.each do |name, arity|
        parsed[name] = parameters.slice!(arity)
      end

      parsed.compact
    end

    def param_completion_for(index:)
      position = 0

      @arguments_range.each do |name, arity|
        if arity.is_a?(Range)
          # Variable param owns all indices from this position onward
          return @completions[name] if index >= position
        else
          # Fixed param owns this exact index
          return @completions[name] if index == position
          position += 1
        end
      end

      nil
    end
  end
end
