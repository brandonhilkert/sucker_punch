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

    def shutdown_timeout
      # 10 seconds on heroku, minus a grace period
      @shutdown_timeout || 8
    end

    def shutdown_timeout=(timeout)
      @shutdown_timeout = timeout
    end
  end
end

at_exit do
  SuckerPunch::Queue.shutdown_all
end

require 'sucker_punch/railtie' if defined?(::Rails)
