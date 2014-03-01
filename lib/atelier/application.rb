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

      Kernel.send(:define_method, :command) do |name, &block|
        Application.instance.load_root_command(name, &block)
      end
    end

    def load_root_command(name, &block)
      @root_command = Command.new(name, &block)
    end

    def locate_command(file_name)
      file_name = file_name.to_s
      return file_name if File.exists?(file_name)
      cmd_path = `which #{file_name}`
      cmd_path.strip! if cmd_path
    end

    def run(command_file, *parameters)
      load(command_file)
      root_command.run(*parameters)
    rescue Exception => e
      logger.error e
    end

  end

end
