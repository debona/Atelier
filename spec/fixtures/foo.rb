# In a real command file, we would have a `require 'atelier'` instead of relying on the FakeGlobals constant.

FakeGlobals.command :foo do |foo|

  foo.title = 'It is a foo'
  foo.description = <<-EOS
    The foo command is used by the test suite.
    The foo command is used by the test suite.
    The foo command is used by the test suite.
  EOS

  # Options
  foo.option(:alert, '-a', '--alert ALERT', 'The alert option')

  # Parameters
  foo.param(:first)
  foo.params(:middles)
  foo.param(:last)

  # Action
  foo.action do |first:, middles:, last: nil|
    {
      command_name: :foo,
      first: first,
      middles: middles,
      last: last,
      options: options,
    }
  end

  # Bar sub-command
  foo.command :bar do |bar|

    bar.title = 'foo command'
    bar.description = 'It will print all the arguments one by line.'

    # Options
    foo.option(:path, '-p', '--path PATH', 'The path option')

    # Action
    bar.action do |*args|
      {
        command_name: :bar,
        args: args,
        options: options,
      }
    end
  end
end
