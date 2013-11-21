
module Rask

  class Library

    attr_reader :name

    def initialize(name, &block)
      @name = name
      instance_eval &block
    end


    private

    def action(action_name, &block)
      (class << self; self; end).send(:define_method, action_name, &block)
    end

  end

end
