require 'atelier/application'

# TODO include a module that cause command is defined
# TODO include the logger method?

module Atelier
  module Globals

    def application
      Atelier::Application.instance
    end

    def command(name, **options, &block)
      loading_command = application.loading_command

      if loading_command
        loading_command.command(name, options, &block)
      else
        application.load_root_command(name, options, &block)
        application.run(*ARGV)
      end
    end
  end
end
