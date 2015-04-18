require 'atelier/application'

# TODO include a module that cause command is defined
# TODO include the logger method?

# FIXME define that in a mixin, and include it in atelier.rb

def command(cmd_name, options = {}, &block)
  app = Atelier::Application.instance
  loading_command = app.loading_command

  if loading_command
    options[:super_command] = loading_command
    command = app.load_command(cmd_name, options, &block)
    loading_command.commands[cmd_name] = command
  else
    app.logger.warn "The root_command '#{app.root_command.name}' is overridden by '#{cmd_name}'" if app.root_command
    app.load_root_command(cmd_name, options, &block)
    app.run(*ARGV)
  end
end
