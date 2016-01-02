require 'concurrent'
require 'concurrent/utility/at_exit'
require 'sucker_punch/core_ext'
require 'sucker_punch/counter'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/shutdown_mode'
require 'sucker_punch/version'
require 'logger'

module SuckerPunch
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
  end
end

require 'sucker_punch/railtie' if defined?(::Rails)
