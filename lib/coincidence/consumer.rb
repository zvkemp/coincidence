module Coincidence
  class Consumer
    include Coincidence::ConsumerBehavior

    def outbox
      @outbox ||= Coincidence::EmptyQueue.new
    end
  end
end
