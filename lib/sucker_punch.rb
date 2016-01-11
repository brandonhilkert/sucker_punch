require 'concurrent'
require 'sucker_punch/core_ext'
require 'sucker_punch/counter'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/version'
require 'logger'

module SuckerPunch
  RUNNING = Concurrent::AtomicBoolean.new(true)

  class << self
    def exception_handler=(handler)
      @exception_handler = handler
    end

    def exception_handler
      @exception_handler || method(:default_exception_handler)
    end

    def default_exception_handler(ex, klass, args)
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

    def shutdown_handler
      @shutdown_handler || method(:default_shutdown_handler)
    end

    def shutdown_handler=(handler)
      @shutdown_handler = handler
    end

    def default_shutdown_handler
      if SuckerPunch::RUNNING.make_false
        logger.info("Shutdown triggered...executing remaining in-process jobs")

        queues = SuckerPunch::Queue.all
        latch = Concurrent::CountDownLatch.new(queues.length)

        queues.each do |queue|
          queue.post(latch) { |l| l.count_down }
          queue.shutdown
        end

        if latch.wait(8) # 10 seconds on heroku, minus a grace period
          logger.info("Remaining jobs have finished")
        else
          queues.each { |queue| queue.kill }
          logger.info("Remaining jobs didn't finish in time...killing remaining jobs")
        end
      end
    end
  end
end

at_exit do
  SuckerPunch.shutdown_handler.call
  SuckerPunch.logger.info("All is quiet...byebye")
end

require 'sucker_punch/railtie' if defined?(::Rails)
