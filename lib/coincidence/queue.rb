require 'securerandom'
module Coincidence
  class Queue
    include MonitorMixin
    attr_reader :stack, :pop_cond, :push_cond, :max_size, :id
    attr_accessor :colorize_output
    attr_accessor :enable_logging

    def initialize(max_size: nil, id: nil)
      @stack     = []
      @pop_cond  = new_cond
      @push_cond = new_cond
      @max_size  = max_size || Float::INFINITY
      @closed    = false
      @id        = id || SecureRandom.hex(5)
      super() # for MonitorMixin
      self.enable_logging = true
    end

    def push(val)
      synchronize do
        push_cond.wait_until { stack.size < max_size }
        log "<< #{val.inspect}".colorize(:yellow)
        stack.push(val)
        pop_cond.signal
      end
    end
    alias_method :<<, :push
    alias_method :enq, :push

    # FIFO
    def pop
      synchronize do
        pop_cond.wait_while { stack.empty? }
        stack.shift.tap do |val|
          log(">> #{val.inspect}".colorize(:magenta))
          push_cond.signal
        end
      end
    end
    alias_method :shift, :pop
    alias_method :deq, :pop

    def empty?
      stack.empty?
    end

    def closed?
      @closed
    end

    def close
      synchronize { @closed = true }
    end

    private

    def log(str)
      puts "#{id_str} #{str}"
    end

    def id_str
      "[#{id} #{stack.size}/#{max_size}]".colorize(colorize_output)
    end
  end
end
