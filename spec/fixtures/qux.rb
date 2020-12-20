# In a real command file, we would have a `require 'atelier'` instead of relying on the FakeGlobals constant.

FakeGlobals.command :qux do |qux|
  qux.title = 'It is a sub sub command'

  # Parameters
  qux.param(:first)

  # Action
  qux.action do |args|
    {
      command_name: :qux,
      args: args,
      options: qux.options,
    }
  end
end
