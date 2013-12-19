#!/usr/bin/env atelier

library :sample do

  load_library 'sub_sample.rb'

  title 'It is a sample'
  description <<-EOS
    This sample is used by the test suite.
    This sample is used by the test suite.
    This sample is used by the test suite.
  EOS

  action :sample_action do
    synopsis    '<args>*'
    description 'It will print all the arguments one by line.'
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

end
