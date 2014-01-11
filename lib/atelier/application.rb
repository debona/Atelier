require 'singleton'
require 'logger'

require 'atelier/library'

module Atelier

  class Application

    include Singleton

    attr_reader :root_library, :logger

    def initialize
      @root_library = nil
      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN

      Kernel.send(:define_method, :library) do |name, &block|
        Application.instance.load_root_library(name, &block)
      end
    end

    def load_root_library(name, &block)
      @root_library = Library.new(name, &block)
    end

    def locate_library(file_name)
      file_name = file_name.to_s
      return file_name if File.exists?(file_name)
      lib_path = `which #{file_name}`
      lib_path.strip! if lib_path
    end

    def send_action(action, *parameters)
      root_library.send(action, *parameters)
    rescue Exception => e
      logger.error e
    end

    def run(library_file, action, *parameters)
      load(library_file)

      send_action(action, *parameters)
    rescue Exception => e
      logger.error e
    end

  end

end
