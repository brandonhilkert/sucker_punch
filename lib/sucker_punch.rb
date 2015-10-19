require 'concurrent'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/version'

module SuckerPunch
  class << self
    attr_accessor :handler

    def exception_handler(&block)
      self.handler = block
    end
  end
  # def self.logger
  #   Concurrent.global_logger
  # end
  #
  # def self.logger=(logger)
  #   Concurrent.global_logger = logger
  # end
  #
end

require 'sucker_punch/railtie' if defined?(::Rails)
