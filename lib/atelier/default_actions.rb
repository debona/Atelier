require 'atelier/action'

module Atelier
  module Default

    COMMANDS = Action.new(:commands) do
      description 'print the sub-commands'
      block { @commands.each { |cmd_name, cmd| puts cmd_name } }
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
