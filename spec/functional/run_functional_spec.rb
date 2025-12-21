require 'spec_helper'

describe "run" do
  context "when no parameters and options are defined" do
    before(:all) do
      FakeGlobals.command :foo do |foo|
        # Action
        foo.action do |*args|
          {
            options: foo.options,
            args: args,
          }
        end
      end
    end

    after(:all) do
      FakeGlobals.reset!
    end

    it "does NOT parse the options" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2')
      expect(result[:options]).to eq Hash[]
    end

    it "does NOT require parameters" do
      result = FakeGlobals.application.run
      expect(result[:args]).to eq []
    end

    it "forwards the parameters" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2')
      expect(result[:args]).to eq ['1', '--alert', 'ALERT_VALUE', '2']
    end
  end

  context "when no parameters are defined but options" do
    before(:all) do
      FakeGlobals.command :foo do |foo|
        # Options
        foo.option(:alert, '-a', '--alert ALERT', 'The alert option')

        # Action
        foo.action do |*args|
          {
            options: foo.options,
            args: args,
          }
        end
      end
    end

    after(:all) do
      FakeGlobals.reset!
    end

    it "parses the options" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2')
      expect(result[:options]).to eq Hash[alert: 'ALERT_VALUE']
    end

    it "fails when an option is unknown" do
      expect(FakeGlobals.application.logger).to receive(:error).with(an_instance_of(OptionParser::InvalidOption))
      result = FakeGlobals.application.run('--unknown', 'UNKNOWN')
      expect(result).to be_a OptionParser::InvalidOption
    end

    it "does NOT require parameters" do
      result = FakeGlobals.application.run('--alert', 'ALERT_VALUE')
      expect(result[:args]).to eq []
    end

    it "forwards the parameters" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2')
      expect(result[:args]).to eq ['1', '2']
    end
  end

  context "when parameters and options are defined" do
    before(:all) do
      FakeGlobals.command :foo do |foo|
        # Options
        foo.option(:alert, '-a', '--alert ALERT', 'The alert option')

        # Parameters
        foo.param(:first)
        foo.params(:middles)
        foo.param(:last)

        # Action
        foo.action do |first:, middles:, last: 'DEFAULT_VALUE'|
          {
            options: foo.options,
            first: first,
            middles: middles,
            last: last,
          }
        end
      end
    end

    after(:all) do
      FakeGlobals.reset!
    end

    it "parses the options" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2')
      expect(result[:options]).to eq Hash[alert: 'ALERT_VALUE']
    end

    it "requires the first parameter" do
      expect(FakeGlobals.application.logger).to receive(:error).with(an_instance_of(ArgumentError))
      result = FakeGlobals.application.run('--alert', 'ALERT_VALUE')
      expect(result).to be_a ArgumentError
    end

    it "parses the first parameter" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE')
      expect(result[:first]).to eq '1'
    end

    it "uses the default value for the last parameters" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE')
      expect(result[:last]).to eq 'DEFAULT_VALUE'
    end

    it "parses the last" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2')
      expect(result[:first]).to eq '1'
      expect(result[:last]).to eq '2'
    end

    it "parses all the parameters" do
      result = FakeGlobals.application.run('1', '--alert', 'ALERT_VALUE', '2', '3', '4')
      expect(result[:first]).to eq '1'
      expect(result[:middles]).to eq ['2', '3']
      expect(result[:last]).to eq '4'
    end
  end
end
