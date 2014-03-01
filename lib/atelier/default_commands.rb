
module Atelier
  module Default

    def load_default_commands

      command(:commands, default: true) do
        description 'print the sub-commands'

        action { @commands.each { |cmd_name, cmd| puts cmd_name } }
      end

      command(:help, default: true) do
        description 'print this message'

        action do
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
end
