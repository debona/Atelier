#!/usr/bin/env rask

library :sample do
  title = 'It is a sample'
  description = <<-EOS
    This sample is used by the test suite.
    This sample is used by the test suite.
    This sample is used by the test suite.
  EOS

  action :sample_action do
    synopsis = 'sample_action <args>*'
    description = 'It will print all the arguments one by line.'
    block do |*args|
      puts 'sample_action called!'
      args.each { |arg| puts "  - #{arg}" }
      args
    end
  end

  action :another_action do
    block do |*args|
      puts 'another_action called!'
      args.each { |arg| puts "  * #{arg}" }
      args
    end
  end

  library :sub_sample do
    title = 'It is a sub library sample (nested in the sample library)'

    action :sub_sample_action do
      block do |*args|
        puts 'sub_sample_action called!'
        args.each { |arg| puts "  - #{arg}" }
        args
      end
    end
  end

end
