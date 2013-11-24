require 'rask/library'

module Rask

  class Factory

    def create(name, &block)
      @lib = Library.new(name)
      instance_eval &block
      @lib
    end

    private

    def action(action_name, &block)
      Application.instance.logger.warn "The method '#{action_name}' is overridden by your provided action" if @lib.methods.include?(action_name.to_sym)
      method(action_name, &block)
    end

    def method(name, &block)
      (class << @lib; self; end).send(:define_method, name, &block)
    end

  end

end
