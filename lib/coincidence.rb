require "coincidence/version"

module Coincidence
  autoload :GenericBehavior, 'coincidence/generic_behavior'
  autoload :ProducerBehavior, 'coincidence/producer_behavior'
  autoload :ConsumerBehavior, 'coincidence/consumer_behavior'
  autoload :Producer, 'coincidence/producer'
  autoload :Consumer, 'coincidence/consumer'
  autoload :ProducerConsumer, 'coincidence/producer_consumer'
  autoload :Queue, 'coincidence/queue'
  autoload :EmptyQueue, 'coincidence/empty_queue'
  autoload :ThreadPool, 'coincidence/thread_pool'

  def self.demo
    require 'colorize'
    producer = Producer.new(pressure: nil)

    quick_doubler = ProducerConsumer.new(subscribe_to: producer, concurrency: 3) do |e|
      sleep(rand) # simulate IO blocking
      e * 2
    end

    slow_consumer = Consumer.new(subscribe_to: quick_doubler, concurrency: 5) do |e|
      sleep(rand * 10)
      puts "Consumed #{e.inspect}"
    end

    # set colors and logging for demo
    producer.outbox.colorize_output = :green
    quick_doubler.inbox.colorize_output = :cyan
    quick_doubler.outbox.colorize_output = :cyan
    slow_consumer.inbox.colorize_output = :blue

    (1..100).each { |i| producer.outbox << i }
    puts ">>>>>>>>>>>>>>>>>>>> DONE ENQUEUEING WORK"
  end
end
