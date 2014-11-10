require 'celluloid'
require 'sucker_punch/core_ext'
require 'sucker_punch/job'
require 'sucker_punch/queue'
require 'sucker_punch/version'

module SuckerPunch
  def self.logger
    Celluloid.logger
  end

  def self.logger=(logger)
    Celluloid.logger = logger
  end

  def self.exception_handler(&block)
    Celluloid.exception_handler(&block)
  end
end

require 'sucker_punch/railtie' if defined?(::Rails)
