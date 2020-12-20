require 'atelier/globals'

class FakeGlobals
  extend Atelier::Globals

  def self.reset!
    @application = Atelier::Application.new
  end

  # Avoid the root_command to run right after loading
  def self.autorun_enabled?
    false
  end
end
