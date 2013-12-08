
module Rask

  module ActionDSL

    def synopsis(*args)
      @synopsis ||= ''
      @synopsis = args.join(' ') unless args.empty?
      @synopsis
    end

    def description(*args)
      @description ||= ''
      @description = args.join("\n") unless args.empty?
      @description
    end

    private

    def block(&proc)
      @proc = proc
    end

  end

end
