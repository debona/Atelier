
module Rask

  class Library

    attr_reader :name

    def initialize(name, &block)
      @name = name
      instance_eval &block
    end


    private

    def action(action_name, &block)
      Application.instance.logger.warn "The method '#{action_name}' is overridden by your provided action" if methods.include?(action_name.to_sym)
      (class << self; self; end).send(:define_method, action_name, &block)
    end

  end

end
