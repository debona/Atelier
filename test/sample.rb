#!/usr/bin/env rask

library :Sample do

  action :action_one do |*args|
    puts 'action_one called!'
    args.each { |arg| puts "  - #{arg}" }

    action_two *args
  end


  action :action_two do |*args|
    puts 'action_two called!'
    args.each { |arg| puts "  * #{arg}" }
  end

end
