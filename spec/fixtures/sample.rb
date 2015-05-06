#!/usr/bin/env ruby

require 'atelier'

command :sample do |sample|

  sample.title = 'It is a sample'
  sample.description = <<-EOS
    This sample is used by the test suite.
    This sample is used by the test suite.
    This sample is used by the test suite.
  EOS

  sample.option(:alert, '-a', '--alert ALERT', 'Alert')

  sample.param(:first)
  sample.params(:middles)
  sample.param(:last)

  sample.action do |arguments|
    puts 'arguments:'
    puts arguments

    puts 'first:'
    puts arguments[:first]
    puts 'middles:'
    puts arguments[:middles]
    puts 'last:'
    puts arguments[:last]

    puts 'options:'
    puts sample.options
  end


  sample.command :sample_command do |sample_command|
    sample_command.title = 'sample command'
    sample_command.description = 'It will print all the arguments one by line.'
    sample_command.action do |*args|
      puts 'sample_command called!'
      args.each { |arg| puts "  - #{arg}" }
      args
    end

    sample_command.command :sub_sample_command do |sub_sample_command|
      sub_sample_command.title = 'sample command'
      sub_sample_command.description = 'It will print all the arguments one by line.'
      sub_sample_command.action do |*args|
        puts 'sub_sample_command called!'
        args.each { |arg| puts "  - #{arg}" }
        args
      end
    end
  end

  sample.command :another_command do |another_command|
    another_command.action do |*args|
      puts 'another_command called!'
      args.each { |arg| puts "  * #{arg}" }
      args
    end
  end

  sample.load_command File.join(File.dirname(__FILE__), 'sub_sample.rb')

end
