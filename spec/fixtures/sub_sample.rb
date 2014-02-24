#!/usr/bin/env atelier


command :sub_sample do
  title 'It is a sub command sample (nested in the sample command)'

  action :sub_sample_action do
    block do |*args|
      puts 'sub_sample_action called!'
      args.each { |arg| puts "  - #{arg}" }
      args
    end
  end
end
