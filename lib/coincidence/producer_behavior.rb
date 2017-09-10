module Coincidence
  module ProducerBehavior
    include GenericBehavior

    def outbox
      @outbox ||= Coincidence::Queue.new(max_size: pressure)
    end

    def get_event
      outbox.pop
    end
  end
end
