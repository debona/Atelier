#!/usr/bin/env ruby

require 'atelier'

command :sub_sample do |sub_sample|
  sub_sample.title = 'It is a sub command sample (nested in the sample command)'

  sub_sample.action do |*args|
    puts 'sub_sample action called!'
    args.each { |arg| puts "  - #{arg}" }
    args
  end
end
