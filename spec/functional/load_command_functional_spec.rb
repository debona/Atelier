require 'spec_helper'

describe "load_command" do
  before(:all) do
    FakeGlobals.command :foo do |foo|
      foo.command :bar do |bar|
        bar.load_command 'qux'
      end
    end
  end

  after(:all) do
    FakeGlobals.reset!
  end

  it "loads the qux command" do
    foo = FakeGlobals.application.root_command
    expect(foo).to be_a Atelier::Command
    expect(foo.name).to eq :foo

    bar = foo.sub_commands_hash[:bar]
    expect(bar).to be_a Atelier::Command
    expect(bar.name).to eq :bar

    qux = bar.sub_commands_hash[:qux]
    expect(qux).to be_a Atelier::Command
    expect(qux.name).to eq :qux
  end

  it "calls the qux action" do
    result = FakeGlobals.application.run('bar', 'qux', 'lol')
    expect(result).to eq Hash[
      command_name: :qux,
      args: { first: 'lol' },
      options: {},
    ]
  end
end
