require 'celluloid'
require 'sucker_punch/exceptions'

module SuckerPunch
  extend self

  def config(&block)
    instance_eval &block
  end

  def queue(options = {})
    raise SuckerPunch::MissingQueueName unless options[:name]
    raise SuckerPunch::MissingWorkerName unless options[:worker]

    klass         = options.fetch(:worker)
    registry_name = options.fetch(:name)
    size          = options.fetch(:size, nil)

    Celluloid::Actor[registry_name] = if size
                                        klass.send(:pool, size: size)
                                      else
                                        klass.send(:pool)
                                      end
  end
end

require 'sucker_punch/queue'
require 'sucker_punch/worker'
require 'sucker_punch/version'