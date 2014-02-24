require 'atelier/action'

module Atelier

  module CommandDSL

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

    def load_command(cmd_name)
      cmd_path = Application.instance.locate_command cmd_name
      cmd_script = File.open(cmd_path).read
      instance_eval(cmd_script)
    end

    def command(cmd_name, &block)
      @commands ||= {}
      command = Command.new(cmd_name, &block)
      @commands[cmd_name] = command
      method(cmd_name) { command }
    end

    def action(action_name, &block)
      @actions ||= {}
      Application.instance.logger.warn "The method '#{action_name}' is overridden by your provided action" if @actions.key?(action_name.to_sym)
      action = Action.new(action_name, &block)
      @actions[action_name] = action
    end

  end

end
