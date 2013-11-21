require 'singleton'
require 'logger'
require 'rask/library'

module Rask

  class Application

    include Singleton

    attr_reader :libraries, :logger

    def initialize
      @libraries = {}
      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN
    end

    def load(name, &block)
      @libraries[name] = Library.new(name, &block)
    end

    def run(*parameters)
      @libraries.first.last.send(*parameters)
    end

  end

end
