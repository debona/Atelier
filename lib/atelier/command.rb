require 'atelier/command_dsl'
require 'atelier/parameterable'
require 'atelier/default_commands'
require 'optparse'

module Atelier
  class Command
    include CommandDSL
    include Parameterable

    attr_accessor :name,
      :super_command,
      :application

    # FIXME Create a class to handle the default command
    def default?
      !!@default
    end

    attr_accessor :title,
      :description

    attr_accessor :commands,
      :option_parser,
      :options_completions,
      :options

    def loading?
      !!@loading
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

      @option_parser   = OptionParser.new
      @options_completions = {}
      @options             = {}

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
        parameters = parse_parameters(argv_without_options)
        return @action&.call(**parameters)
      end
    end

    # FIXME all the options management should be in a mixin
    def available_switches
      switches = @option_parser.top.list # give the list of the custom switches
      Array.new(switches)
    end

    def available_switche_names
      names = available_switches.collect { |switch| [switch.long, switch.short] }
      names.flatten
    end

    private

    def parse_options!(parameters)
      if !available_switches.empty?
        @option_parser.parse(parameters)
      else
        parameters
      end
    end

    def inspect
      "#<#{self.class.name}:#{object_id} @name=#{name.inspect}, @commands=#{commands.keys.inspect}>"
    end
  end
end
