#!/usr/bin/env ruby

require 'atelier'

command :sample do

  load_command File.join(File.dirname(__FILE__), 'sub_sample.rb')

  title 'It is a sample'
  description <<-EOS
    This sample is used by the test suite.
    This sample is used by the test suite.
    This sample is used by the test suite.
  EOS

  action { run(:help) }

  command :sample_command do
    title 'sample command'
    description 'It will print all the arguments one by line.'
    action do |*args|
      puts 'sample_command called!'
      args.each { |arg| puts "  - #{arg}" }
      args
    end
  end

  command :another_command do
    action do |*args|
      puts 'another_command called!'
      args.each { |arg| puts "  * #{arg}" }
      args
    end
  end

end
