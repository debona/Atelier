require 'atelier/application'

# TODO include a module that cause command is defined
# TODO include the logger method?

module Atelier

  module Globals

    def command(cmd_name, options = {}, &block)
      app = Atelier::Application.instance
      loading_command = app.loading_command

      if loading_command
        loading_command.command(cmd_name, options, &block)
      else
        app.logger.warn "The root_command '#{app.root_command.name}' is overridden by '#{cmd_name}'" if app.root_command
        app.load_root_command(cmd_name, options, &block)
        app.run(*ARGV)
      end
    end

  end

end
