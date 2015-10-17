require 'concurrent'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/version'

module SuckerPunch
  # def self.logger
  #   Concurrent.global_logger
  # end
  #
  # def self.logger=(logger)
  #   Concurrent.global_logger = logger
  # end
  #
  # def self.exception_handler(&block)
  #   Celluloid.exception_handler(&block)
  # end
end

require 'sucker_punch/railtie' if defined?(::Rails)
