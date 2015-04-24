require 'singleton'
require 'logger'

require 'atelier/command'

module Atelier

  class Application

    include Singleton

    attr_reader :root_command, :logger

    def initialize
      @root_command = nil
      @logger = Logger.new(STDERR) # TODO: make a module with that
      @logger.level = Logger::WARN
    end

    def loading_command
      return nil unless @root_command && @root_command.loading?

      command = @root_command

      while command.commands.values.select(&:loading?).last # while there is a loading sub command
        command = command.commands.values.select(&:loading?).last
      end

      command
    end

    def load_root_command(name, options = {}, &block)
      logger.warn "The root_command '#{root_command.name}' is overridden by '#{name}'" if root_command
      @root_command = Command.new(name, options)
      @root_command.load(&block)
      @root_command
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
