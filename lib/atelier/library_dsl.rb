require 'atelier/action'

module Atelier

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

    def load_library(lib_name)
      lib_path = Application.instance.locate_library lib_name
      lib_script = File.open(lib_path).read
      instance_eval(lib_script)
    end

    def library(lib_name, &block)
      @libraries ||= {}
      library = Library.new(lib_name, &block)
      @libraries[lib_name] = library
      method(lib_name) { library }
    end

    def action(action_name, &block)
      @actions ||= {}
      Application.instance.logger.warn "The method '#{action_name}' is overridden by your provided action" if @actions.key?(action_name.to_sym)
      action = Action.new(action_name, &block)
      @actions[action_name] = action
    end

  end

end
