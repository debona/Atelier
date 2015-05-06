require 'atelier/argument_parser'

module Atelier

  module CommandDSL

    def option(name, *opt_parser_args)
      @options ||= {}
      @option_parser ||= OptionParser.new
      @option_parser.on(*opt_parser_args) do |o|
        @options[name] = o
      end
    end

    def param(param_name)
      @argument_parser ||= ArgumentParser.new
      @argument_parser.param(param_name)
    end

    def params(params_name)
      @argument_parser ||= ArgumentParser.new
      @argument_parser.params(params_name)
    end

    def action(&block)
      @action = block if block
      @action
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
