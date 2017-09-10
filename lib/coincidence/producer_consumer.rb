module Coincidence
  class ProducerConsumer
    include Coincidence::ProducerBehavior
    include Coincidence::ConsumerBehavior
  end
end

