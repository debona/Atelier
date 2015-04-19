require 'atelier/arguments_parser'

module Atelier

  module CommandDSL

    def param(param_name)
      @arguments_parser ||= ArgumentsParser.new
      @arguments_parser.param(param_name)
    end

    def params(params_name)
      @arguments_parser ||= ArgumentsParser.new
      @arguments_parser.params(params_name)
    end

    def action(&block)
      @action = block if block
      @action
    end

    def method(name, &block)
      (class << self; self; end).send(:define_method, name, &block)
    end

    def load_command(cmd_name)
      cmd_path = Application.instance.locate_command cmd_name # FIXME stop depending on App singleton
      require(cmd_path) unless cmd_path.nil? || cmd_path.empty?
    end

    def command(cmd_name, options = {}, &block)
      @commands ||= {}
      options[:super_command] = self
      command = Command.new(cmd_name, options)
      @commands[cmd_name] = command
      command.load(&block)
    end

  end

end
