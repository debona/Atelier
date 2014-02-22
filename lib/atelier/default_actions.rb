require 'atelier/action'

module Atelier
  module Default

    def libraries
      @libraries.each { |lib_name, lib| puts lib_name }
      @libraries
    end

    def actions
      @actions.each { |action_name, action| puts action_name }
      @actions
    end

    def help
      puts "#{name}: #{title}"

      puts 'default actions:'
      @actions.each do |action_name, action|
        puts "  - #{name} #{action_name}" if action == :default
      end

      puts 'actions:'
      @actions.each do |action_name, action|
        puts "  - #{name} #{action_name} #{action.synopsis}" unless action == :default
      end
    end
  end
end
