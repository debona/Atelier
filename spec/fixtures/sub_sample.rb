#!/usr/bin/env atelier


library :sub_sample do
  title 'It is a sub library sample (nested in the sample library)'

  action :sub_sample_action do
    block do |*args|
      puts 'sub_sample_action called!'
      args.each { |arg| puts "  - #{arg}" }
      args
    end
  end
end
