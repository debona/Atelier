require 'atelier/application'

def command(cmd_name, options = {}, &block)
  Atelier::Application.instance.load_root_command(cmd_name, options, &block)
end
