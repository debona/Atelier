#!/usr/bin/env rask

library :sample do

  title = 'It is a sample'
  description = <<-EOS
    This sample is used by the test suite.
    This sample is used by the test suite.
    This sample is used by the test suite.
  EOS

  action :sample_action do |*args|
    puts 'sample_action called!'
    args.each { |arg| puts "  - #{arg}" }
    args
  end

  action :another_action do |*args|
    puts 'another_action called!'
    args.each { |arg| puts "  * #{arg}" }
    args
  end

  library :sub_sample do

    title = 'It is a sub library sample (nested in the sample library)'
    description = <<-EOS
      This sample is used by the test suite.
      This sample is used by the test suite.
      This sample is used by the test suite.
    EOS

    action :sub_sample_action do |*args|
      puts 'sub_sample_action called!'
      args.each { |arg| puts "  - #{arg}" }
      args
    end

  end

end
