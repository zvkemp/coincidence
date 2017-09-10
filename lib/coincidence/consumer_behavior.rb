module Coincidence
  module ConsumerBehavior
    include GenericBehavior
    attr_reader :producer, :handler, :pool, :fetcher

    def initialize(subscribe_to:, concurrency: 1, pressure: 5)
      super
      @producer = subscribe_to
      @handler = Proc.new
      @pool = Coincidence::ThreadPool.new(size: concurrency, inbox: inbox, outbox: outbox, handler: handler)
      @fetcher = Thread.new { loop { inbox << producer.get_event } }
    end

    def inbox
      @inbox ||= Coincidence::Queue.new(max_size: pressure)
    end

    def detach
      # TODO: handle inbox draining? Pass unprocessed queue back to producer?
      fetcher.terminate
      pool.terminate
    end
  end
end
