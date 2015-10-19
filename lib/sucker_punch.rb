require 'concurrent'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/version'
require 'logger'

module SuckerPunch
  class << self
    attr_accessor :handler, :logger

    def exception_handler(&block)
      self.handler = block
    end

    def logger
      @logger || Logger.new(STDOUT)
    end
  end
end

require 'sucker_punch/railtie' if defined?(::Rails)
