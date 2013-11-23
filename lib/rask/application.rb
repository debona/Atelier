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
    end

    def load(name, &block)
      @library = @factory.create(name, &block)
    end

    def run(*parameters)
      library.send(*parameters)
    rescue Exception => e
      logger.error e
    end

  end

end
