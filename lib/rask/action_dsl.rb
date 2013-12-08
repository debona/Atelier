
module Rask

  module ActionDSL

    attr_reader :synopsis, :description

    private

    attr_writer :synopsis, :description

    def block(&proc)
      @proc = proc
    end

  end

end
