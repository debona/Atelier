require 'singleton'
require 'logger'

require 'rask/factory'

module Rask

  class Application

    include Singleton

    attr_reader :library, :logger

    def initialize
      @factory = Factory.new
      @library = nil
      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN

      Kernel.send(:define_method, :library) do |name, &block|
        Application.instance.load_library(name, &block)
      end
    end

    def load_library(name, &block)
      @library = @factory.create(name, &block)
    end

    def send_action(action, *parameters)
      library.send(action, *parameters)
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
