require 'atelier/application'

# TODO include the logger method?

module Atelier
  module Globals
    extend self

    def application
      @application ||= Atelier::Application.new
    end

    def command(name, **options, &block)
      if application.root_command.nil?
        application.load_root_command(name, options, &block)
        application.run(*ARGV)
      elsif application.loading_command
        application.loading_command.command(name, options, &block)
      else
        raise "There already is a root command and there are no more loading commands."
      end
    end
  end
end
