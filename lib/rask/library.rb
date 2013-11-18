
module Rask

  class Library

    def initialize(name, &block)
      instance_eval &block
    end


    private

    def action(action_name, &block)
      (class << self; self; end).send(:define_method, action_name, &block)
    end

  end

end
