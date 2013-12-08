require 'rask/action_dsl'

module Rask

  class Action

    include ActionDSL

    attr_reader :name, :proc

    def initialize(name, &init_block)
      @name = name
      @proc = Proc.new {}
      instance_eval &init_block
    end

  end

end
