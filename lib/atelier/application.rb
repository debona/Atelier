require 'logger'

require 'atelier/command'
require 'atelier/defaults'

module Atelier
  class Application
    attr_reader :root_command, :logger

    def initialize
      @root_command = nil
      @logger = Logger.new(STDERR) # TODO: make a module with that
      @logger.level = Logger::WARN
    end

    def define_root_command(name, **options, &block)
      logger.warn "The root_command '#{root_command.name}' is overridden by '#{name}'" if root_command
      @root_command = Command.new(name, application: self, **options)
      @root_command.load(&block)
      @root_command
    end

    def run(*parameters)
      root_command.run(*parameters)
    rescue Exception => e
      logger.error e
      # TODO set exit status?
      e
    end

    def command_load_requested?
      !!@command_load_requester
    end

    def request_command_load(command_load_requester, cmd_name)
      cmd_name = cmd_name.to_s
      @command_load_requester = command_load_requester
      load(cmd_name)
    rescue LoadError
      # Mimic the require behavior that make require 'foo' => loading the foo.rb file
      if cmd_name.downcase.end_with?('.rb')
        raise
      else
        load("#{cmd_name}.rb")
      end
    ensure
      @command_load_requester = nil
    end

    def load_requested_command(name, **options, &block)
      @command_load_requester.command(name, options, &block)
    end
  end
end
