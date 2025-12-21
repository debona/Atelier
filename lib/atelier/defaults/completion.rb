require 'atelier/default_command'

module Atelier
  module Defaults
    module Completion

      def self.factory(super_command)
        Atelier::DefaultCommand.new(:completion, super_command: super_command) do |completion|
          completion.title = ''
          completion.description = 'Enable the completion with: eval "$(my_command.rb completion)"'

          completion.param :program_name

          completion.action do |program_name: nil|
            executable_name = program_name || File.basename($PROGRAM_NAME)
            case ENV["SHELL"].split("/").last
            when "bash"
              puts <<~SCRIPT
                function __atelier_completion() {
                  local cmd=$1
                  shift
                  $cmd complete "$@"
                }
                function __completion__handler() {
                  COMPREPLY=( $( __atelier_completion "${COMP_WORDS[@]}" ) )
                }
                complete -o bashdefault -o default -F __completion__handler "#{executable_name}"
              SCRIPT
            when "zsh"
              puts <<~SCRIPT
                function _atelier_zsh_completion() {
                  local -a completions
                  completions=(${(f)"$(${words[1]} complete ${words[@]:1})"})
                  compadd -a completions
                }
                compdef _atelier_zsh_completion "#{executable_name}"
              SCRIPT
            end
          end
        end
      end

    end
  end
end
