module Atelier
  module CommandDSL

    def option(name, *opt_parser_args, &completion_block)
      @options ||= {}
      @options_completions ||= {}
      @option_parser ||= OptionParser.new

      switches_before = Array.new(@option_parser.top.list)
      @option_parser.on(*opt_parser_args) do |o|
        @options[name] = o
      end
      return unless block_given?

      new_switch = (@option_parser.top.list - switches_before).first

      longs_and_shorts = (new_switch.long + new_switch.short).flatten
      longs_and_shorts.each { |name| @options_completions[name] = completion_block }
    end


    def action(&block)
      @action = block if block_given?
      @action
    end

    def load_command(cmd_name)
      cmd_path = application.locate_command cmd_name
      require(cmd_path) unless cmd_path.nil? || cmd_path.empty?
    end

    def command(cmd_name, **options, &block)
      @commands ||= {}
      options[:super_command] = self
      command = Command.new(cmd_name, options)
      @commands[cmd_name] = command
      command.load(&block)
    end
  end
end
