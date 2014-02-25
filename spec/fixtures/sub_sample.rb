#!/usr/bin/env atelier


command :sub_sample do
  title 'It is a sub command sample (nested in the sample command)'

  action do |*args|
    puts 'sub_sample_action called!'
    args.each { |arg| puts "  - #{arg}" }
    args
  end
end
