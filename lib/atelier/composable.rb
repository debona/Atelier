module Atelier
  module Composable

    def load_command(cmd_name)
      cmd_path = application.locate_command(cmd_name)
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
