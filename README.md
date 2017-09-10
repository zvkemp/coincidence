# Coincidence

Coincidence is an early implementation of a Producer-Consumer data flow model in Ruby. It's in early stages, and highly subject to significant changes. Conceptually inspired by Elixir's GenStage and Flow.

## Installation

Have a project you're willing to sacrifice (read: not in production yet, please)? Add this line to your application's Gemfile:

```ruby
gem 'coincidence'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coincidence

## Usage

See the `Coincidence.demo` method for an example dataflow:

```ruby
producer = Producer.new(pressure: nil)

quick_doubler = ProducerConsumer.new(subscribe_to: producer, concurrency: 3, pressure: 5) do |e|
  sleep(rand) # simulate IO work
  e * 2
end

slow_consumer = Consumer.new(subscribe_to: quick_doubler, concurrency: 5, pressure: 5) do |e|
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
```

What will happen:
1. The work should enqueue immediately into the producer (since its queue is set up with no backpressure, it shouldn't block the main thread)
1. The intermediate stage (`quick_doubler`) will start consuming events out of the producer, and will accept a maximum of 5 into its inbox.
1. `quick_doublers` thread pool will begin working on these events (there's a small `sleep` here to simulate work), and then:
  - pop the result into the outbox, if the outbox has space
  - if the outbox is full, it waits until the next stage has drained at least one event. This waiting behavior will echo back through the pipeline, meaning the fetcher will also stop requesting new events from the producer. Since we configured this producer-consumer with a pool size of three, and pressure of 5, at any given time there will be a maximum of 5 events in the inbox waiting to be processed, 3 processing events in the thread pool, and 5 processed events in the outbox.
1. The final consumer will read from the producer-consumer, also with backpressure (this step has been configured to simulate slower work).

Implementation Characteristics:

- Each stage of a pipeline can be individually tuned to provide backpressure. In the case of ProducerConsumers, this can be on both the incoming and outgoing streams.
- Since the concurrency model is currently based *only* on threads, this project is really only useful for composing IO-heavy dataflows
- The Queue class shares a lot of the same characterics of the stdlib's `Thread::{Sized}Queue`, but I wanted to see how much work it would be to reimplement in ruby (turns out: not much)

Planned behaviors:
- `map` (eventually-correct ordering)
- `enum` (processed events are yielded to an Enumerator)
- `fanout` (events can be propogated from a single producer to multiple consumers)

Planned Improvements:
- error handling / signal traps (currently, there is none)
- thread pool cleanup
- infinite streams (this is more or less already possible, just untested)
- good way to run this in rspec
- add option to replace thread pools with subprocesses


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zvkemp/coincidence.

