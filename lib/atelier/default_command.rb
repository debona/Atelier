require 'atelier/command'

module Atelier
  class DefaultCommand < Atelier::Command
    def initialize(name, super_command:, application: super_command&.application, &block)
      super(name, super_command: super_command, application: application, defaults: [], &block)
    end
  end
end
