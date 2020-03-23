require 'atelier/composable'
require 'atelier/parameterable'
require 'atelier/optionable'
require 'atelier/default_commands'

module Atelier
  class Command
    include Composable
    include Parameterable
    include Optionable

    attr_accessor :name,
      :super_command,
      :application

    # FIXME Create a class to handle the default command
    def default?
      !!@default
    end

    attr_accessor :title,
      :description

    attr_accessor :commands

    def loading?
      !!@loading
    end

    def action(&block)
      @action = block if block_given?
      @action
    end

    def initialize(name, super_command: nil, application: super_command&.application, default: false, &block)
      @name          = name
      @super_command = super_command
      @application   = application
      @default       = default

      @title           = nil
      @description     = nil
      @action          = nil

      # TODO the commands hash should be renamed commands_by_name
      # TODO commands should be an array implemented as commands_by_name.values
      # TODO sharing all default commands is faster but more complicated
      @commands = default? ? {} : ::Atelier::Default.all

      # FIXME technically, it's not currently loading. So why block_given? was useful?
      @loading = false # block_given?
      load(&block) if block_given?
    end

    # TODO A callback system may be useful
    def load
      @loading = true
      yield(self)
      @loading = false
    end

    def loading_command
      return nil unless loading?
      last_loading_command = commands.values.select(&:loading?).last
      last_loading_command&.loading_command || self
    end

    def run(*argv)
      if commands[argv.first&.to_sym]
        # TODO a private subcommand(for:) method may be more readable
        # TODO in a same way, a run_subcommand method would be more readable too
        cmd_name = argv.shift.to_sym
        command = commands[cmd_name]
        # FIXME this is really strange. It requires at least a clear explanation
        command.super_command = self # useful for default commands
        return command.run(*argv)
      else
        argv_without_options = parse_options!(argv)
        argv_or_parameters_hash = parse_parameters(argv_without_options)
        if Array === argv_or_parameters_hash
          return @action&.call(*argv_or_parameters_hash)
        else
          return @action&.call(**argv_or_parameters_hash)
        end
      end
    end

    private

    def inspect
      "#<#{self.class.name}:#{object_id} @name=#{name.inspect}, @commands=#{commands.keys.inspect}>"
    end
  end
end
