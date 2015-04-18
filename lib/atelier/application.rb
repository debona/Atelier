require 'singleton'
require 'logger'

require 'atelier/command'

module Atelier

  class Application

    include Singleton

    attr_reader :root_command, :logger

    def initialize
      @loading_commands = []
      @root_command = nil
      @logger = Logger.new(STDERR) # TODO: make a module with that
      @logger.level = Logger::WARN
    end

    def loading_command
      @loading_commands.last
    end

    def load_root_command(name, options = {}, &block)
      @root_command = Command.new(name, options)
      @loading_commands << @root_command
      yield(@root_command)
      @loading_commands.pop
      root_command
    end

    def load_command(name, options = {}, &block)
      command = Command.new(name, options)
      @loading_commands << command
      yield(command)
      @loading_commands.pop
      command
    end

    def locate_command(file_name)
      file_name = file_name.to_s
      absolute_path = File.absolute_path(file_name)

      return absolute_path if File.exists?(absolute_path)
      cmd_path = `which #{file_name}`
      cmd_path.strip! if cmd_path
    end

    def run(*parameters)
      root_command.run(*parameters)
    rescue Exception => e
      logger.error e
      # TODO set exit status
    end

  end

end
