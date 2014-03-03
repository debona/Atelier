require 'atelier/arguments_parser'

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

    def param(param_name)
      @arguments_parser ||= ArgumentsParser.new
      @arguments_parser.param(param_name)
    end

    def action(&block)
      @action = block if block
      @action
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

    def command(cmd_name, options = {}, &block)
      @commands ||= {}
      command = Command.new(cmd_name, options, &block)
      @commands[cmd_name] = command
      command.super_command = self
    end

  end

end
