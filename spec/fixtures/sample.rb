#!/usr/bin/env rask

library :sample do

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

end
