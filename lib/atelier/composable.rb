module Atelier
  module Composable

    def sub_commands_hash
      @sub_commands_hash ||= {}
    end

    def sub_command_names
      sub_commands_hash.keys
    end

    def sub_commands
      sub_commands_hash.values
    end


    def load_command(cmd_name)
      cmd_path = application.locate_command(cmd_name)
      # FIXME unfortunately `require` prevents the reuse of commands defined in files
      require(cmd_path) unless cmd_path.nil? || cmd_path.empty?
    end

    def command(cmd_name, **options, &block)
      options[:super_command] = self
      new_command = Command.new(cmd_name, options)
      sub_commands_hash[cmd_name] = new_command
      new_command.load(&block)
      new_command
    end
  end
end
