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

    def load_root_command(name, options= {}, &block)
      @root_command = Command.new(name, options, &block)
    end

    def locate_command(file_name)
      file_name = file_name.to_s
      return file_name if File.exists?(file_name)
      cmd_path = `which #{file_name}`
      cmd_path.strip! if cmd_path
    end

    def run(*parameters)
      root_command.run(*parameters)
    rescue Exception => e
      logger.error e
    end

  end

end
