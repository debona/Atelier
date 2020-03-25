require 'atelier/application'

# TODO include the logger method?

module Atelier
  module Globals
    extend self

    def application
      @application ||= Atelier::Application.new
    end

    def command(name, **options, &block)
      root_command = application.root_command

      if root_command.nil?
        application.define_root_command(name, options, &block)
        application.run(*ARGV)
      elsif application.command_load_requested?
        application.load_requested_command(name, options, &block)
      else
        raise "There already is a root command and there are no command loading requested."
      end
    end
  end
end
