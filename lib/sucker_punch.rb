require 'celluloid'
require 'sucker_punch/exceptions'
require 'sucker_punch/queue'
require 'sucker_punch/worker'
require 'sucker_punch/api'
require 'sucker_punch/version'

module SuckerPunch
  def self.config(&block)
    instance_eval &block
  end

  def self.queue(options = {})
    raise MissingQueueName unless options[:name]
    raise MissingWorkerName unless options[:worker]

    klass = options.fetch(:worker)
    name = options.fetch(:name)
    workers = options.fetch(:workers, nil)

    q = Queue.new(name)
    q.register(klass, workers)

    SuckerPunch::API::Queues.register(name)
  end

  def self.logger
    Celluloid.logger
  end

  def self.logger=(logger)
    Celluloid.logger = logger
  end
end

require 'sucker_punch/railtie' if defined?(::Rails)
