require 'rask/library'

module Rask

  module LibraryDSL

    private

    def library(lib_name, &block)
      @libraries ||= {}
      library = Library.new(lib_name, &block)
      @libraries[lib_name] = library
      method(lib_name) do |*args|
        if args.empty?
          library
        else
          library.send(*args)
        end
      end
    end

    def action(action_name, &block)
      @actions ||= {}
      Application.instance.logger.warn "The method '#{action_name}' is overridden by your provided action" if methods.include?(action_name.to_sym)
      @actions[action_name] = block
      method(action_name, &block)
    end

    def method(name, &block)
      (class << self; self; end).send(:define_method, name, &block)
    end

  end

end
