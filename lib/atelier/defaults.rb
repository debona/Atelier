Dir["#{__dir__}/defaults/*.rb"].each do |f|
  require f
end

module Atelier
  module Defaults
    FACTORY_MAP = {
      help: Atelier::Defaults::Help,
      completion: Atelier::Defaults::Completion,
      commands: Atelier::Defaults::Commands,
      complete: Atelier::Defaults::Complete,
    }

    ALL = FACTORY_MAP.keys

    def self.factory(default_name, super_command)
      default_name = default_name.to_sym

      if cmd_module = FACTORY_MAP[default_name]
        cmd_module.factory(super_command)
      else
        raise ArgumentError, "DefaultCommand #{default_name} not found"
      end
    end
  end
end
