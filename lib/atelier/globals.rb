require 'atelier/application'

def pre_command(cmd_name, options = {}, &block)

end

def post_command(cmd_name, options = {}, &block)
  Atelier::Application.instance.run(*ARGV)
end

def command(cmd_name, options = {}, &block)
  pre_command(cmd_name, options, &block)
  Atelier::Application.instance.load_root_command(cmd_name, options, &block)
  post_command(cmd_name, options, &block)
end
