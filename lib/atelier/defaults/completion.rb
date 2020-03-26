require 'atelier/default_command'

module Atelier
  module Defaults
    module Completion

      def self.factory(super_command)
        Atelier::DefaultCommand.new(:completion, super_command: super_command) do |completion|
          completion.title = ''
          completion.description = 'Enable the completion with: eval "$(my_command.rb completion)"'

          completion.action do
            executable_name = File.basename($PROGRAM_NAME)
            puts <<~EOS
              function __atelier_completion() {
                local cmd=$1
                shift
                $cmd complete "$@"
              }
              function __completion__handler() {
                COMPREPLY=( $( __atelier_completion "${COMP_WORDS[@]}" ) )
              }
              complete -o bashdefault -o default -F __completion__handler "#{executable_name}"
            EOS
          end
        end
      end

    end
  end
end
