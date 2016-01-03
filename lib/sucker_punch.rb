require 'concurrent'
require 'sucker_punch/core_ext'
require 'sucker_punch/counter'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/shutdown_mode'
require 'sucker_punch/version'
require 'logger'

module SuckerPunch

  RUNNING = Concurrent::AtomicBoolean.new(true)

  class << self
    def exception_handler(&block)
      @handler = block
    end

    def handler
      @handler || method(:default_handler)
    end

    def default_handler(ex, klass, args)
      msg = "Sucker Punch job error for class: '#{klass}' args: #{args}\n"
      msg += "#{ex.class} #{ex}\n"
      msg += "#{ex.backtrace.nil? ? '' : ex.backtrace.join("\n")}"
      logger.error msg
    end

    def logger
      @logger || default_logger
    end

    def logger=(log)
      @logger = (log ? log : Logger.new('/dev/null'))
    end

    def default_logger
      l = Logger.new(STDOUT)
      l.level = Logger::INFO
      l
    end

    def shutdown_mode
      @shutdown_mode || :soft
    end

    def shutdown_mode=(mode)
      @shutdown_mode = mode.to_sym if mode
    end

    def shutdown
      # The #make_false method returns true when the value changes,
      # so this will only run the first time the method is called.
      if SuckerPunch::RUNNING.make_false
        stopped = false
        queues = SuckerPunch::Queue::QUEUES

        if shutdown_mode == :none
          print "Left jab to all jobs waiting in the queue...\n"
          # attempt to let all queued jobs finish
          shutdown_latch = Concurrent::CountDownLatch.new(queues.size)
          queues.each_value do |queue|
            queue.post(shutdown_latch) { |latch| latch.count_down  }
          end

          # wait for all thread pools to clear their queues
          # `stopped` will be set to true if all pools clear
          # the wait time here could be configurable
          stopped = shutdown_latch.wait(10)
          if stopped
            print "Lights out!\n"
            return
          end
        end

        if !stopped || shutdown_mode == :soft
          print "Right uppercut to all thread pools...\n"
          # attempt to gracefully shutdown all thread pools
          # wait a pre-determined for each thread pool to shutdown
          # the wait time here is also configurable
          stopping = []
          queues.each_value do |queue|
            queue.shutdown
            stopping << queue
          end

          # this is imperfect because the first queue in the collection is given less time
          # the only way to accurately track total time is to spawn more threads
          # we'll go with this for now because it's simpler
          stopped = stopping.all? { |queue| queue.wait_for_termination(1) }
          if stopped
            print "Lights out!\n"
            return
          end
        end

        if !stopped # || shutdown_mode == :hard
          print "it's clobberin' time...\n"
          # brutally kill all thread pools
          # we could call #wait_for_termination here, too, using the above method
          queues.each_value { |queue| queue.kill }
        end
      end
    end
  end
end

# here is where the shutdown magic occurs...
at_exit do
  puts "Shutting down Sucker Punch..."
  SuckerPunch.shutdown
  puts "Sucker Punch is down for the count."
end

require 'sucker_punch/railtie' if defined?(::Rails)
