require 'atelier/argument_parser'

module Atelier
  module Parameterable

    def param(param_name)
      argument_parser.param(param_name)
    end

    def params(params_name)
      argument_parser.params(params_name)
    end

    def argument_parser
      @argument_parser ||= ArgumentParser.new
    end

    def parse_parameters(parameters)
      if argument_parser.declared_params.any?
        argument_parser.parse(parameters)
      else
        parameters
      end
    end
  end
end
