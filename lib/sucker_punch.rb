require 'celluloid'
require 'sucker_punch/exceptions'
require 'sucker_punch/queue'
require 'sucker_punch/worker'
require 'sucker_punch/version'

module SuckerPunch
  extend self

  def config(&block)
    instance_eval &block
  end

  def queue(options = {})
    raise MissingQueueName unless options[:name]
    raise MissingWorkerName unless options[:worker]

    klass         = options.fetch(:worker)
    registry_name = options.fetch(:name)
    size          = options.fetch(:size, nil)

    q = Queue.new(registry_name)
    q.register(klass, size)
  end
end