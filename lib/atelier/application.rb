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
