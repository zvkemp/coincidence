module Coincidence
  class ThreadPool

    attr_reader :queue, :handler, :pool

    def initialize(size:, inbox:, outbox:, handler:)
      @inbox   = inbox
      @outbox  = outbox
      @handler = handler
      @pool    = Array.new(size) do
        Thread.new do
          loop { outbox << handler.call(inbox.pop) }
        end
      end
    end

    def terminate
      # TODO:
      @pool.each(&:terminate)
    end
  end
end
