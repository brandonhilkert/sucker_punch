require 'concurrent'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/version'
require 'logger'

module SuckerPunch
  class << self
    attr_accessor :handler

    def exception_handler(&block)
      self.handler = block
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
  end
end

require 'sucker_punch/railtie' if defined?(::Rails)
