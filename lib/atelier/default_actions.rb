require 'atelier/action'

module Atelier
  module Default

    LIBRARIES = Action.new(:libraries) do
      description 'print the sub-libraries'
      block { @libraries.each { |lib_name, lib| puts lib_name } }
    end

    ACTIONS = Action.new(:actions) do
      description 'print the sub-actions'
      block { @actions.each { |action_name, action| puts action_name } }
    end

    HELP = Action.new(:help) do
      description 'print this message'
      block do
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
end
