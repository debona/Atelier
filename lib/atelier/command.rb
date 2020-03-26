require 'atelier/composable'
require 'atelier/parameterable'
require 'atelier/optionable'

module Atelier
  class Command
    include Composable
    include Parameterable
    include Optionable

    # Options
    attr_accessor :name,
      :super_command,
      :application,
      :defaults

    attr_accessor :title,
      :description


    def action(&block)
      @action = block if block_given?
      @action
    end

    def initialize(name, super_command: nil, application: super_command&.application, defaults: Defaults::ALL, &block)
      @name = name
      @super_command = super_command
      @application = application
      @defaults = defaults

      @title = nil
      @description = nil
      @action = nil

      load(&block) if block_given?
    end

    # TODO A callback system may be useful
    def load
      @defaults.each do |default_name|
        default_cmd = Defaults.factory(default_name, self)
        sub_commands_hash[default_name] = default_cmd
      end
      yield(self)
    end


    def run(*argv)
      if sub_command = sub_commands_hash[argv.first&.to_sym]
        argv.shift
        return sub_command.run(*argv)
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
      "#<#{self.class.name}:#{object_id} @name=#{name.inspect}, sub_command_names=#{sub_command_names.inspect}>"
    end
  end
end
