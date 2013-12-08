require 'rask/library_dsl'

module Rask

  class Library

    include LibraryDSL

    attr_reader :name

    def initialize(name, &block)
      @name = name
      @title = ''
      @description = ''
      @libraries = {}
      @actions = {
        libraries: :default,
        actions: :default,
        help: :default
      }
      instance_eval &block
    end

    def libraries
      @libraries.each { |lib_name, lib| puts lib_name }
      @libraries
    end

    def actions
      @actions.each { |action_name, action| puts action_name }
      @actions
    end

    def help
      puts "#{name}: #{title}"

      puts 'default actions:'
      @actions.each do |action_name, action|
        puts "  - #{name} #{action_name}" if action == :default
      end

      puts 'actions:'
      @actions.each do |action_name, action|
        puts "  - #{name} #{action_name} #{action.synopsis}" unless action == :default
      end
    end

  end

end
