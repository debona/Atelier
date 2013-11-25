require 'rask/library'

module Rask

  class Factory

    def create(name, &block)
      @lib = Library.new(name)
      instance_eval &block
      @lib
    end

    private

    def library(lib_name, &block)
      library = Factory.new.create(lib_name, &block)
      @lib.instance_eval { @libraries[lib_name] = library }
      method(lib_name) do |*args|
        if args.empty?
          library
        else
          library.send(*args)
        end
      end
    end

    def action(action_name, &block)
      Application.instance.logger.warn "The method '#{action_name}' is overridden by your provided action" if @lib.methods.include?(action_name.to_sym)
      @lib.instance_eval { @actions[action_name] = block }
      method(action_name, &block)
    end

    def method(name, &block)
      (class << @lib; self; end).send(:define_method, name, &block)
    end

  end

end
