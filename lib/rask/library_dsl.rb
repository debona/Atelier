require 'rask/Action'

module Rask

  module LibraryDSL

    def title(*args)
      @title ||= ''
      @title = args.join(' ') unless args.empty?
      @title
    end

    def description(*args)
      @description ||= ''
      @description = args.join("\n") unless args.empty?
      @description
    end

    private

    def method(name, &block)
      (class << self; self; end).send(:define_method, name, &block)
    end

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
      action = Action.new(action_name, &block)
      @actions[action_name] = action
      method(action_name, &action.proc)
    end

  end

end
