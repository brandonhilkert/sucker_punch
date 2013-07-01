module SuckerPunch
  module Job
    def self.included(base)
      base.send(:include, ::Celluloid)
      base.class_eval do
        alias_method :perform_without_pool_check, :perform
        alias_method :perform, :perform_with_pool_check
      end
    end

    def perform_with_pool_check(*args, &block)
      define_celluloid_pool
      perform_without_pool_check(*args, &block)
    end

    private

    def define_celluloid_pool
      unless SuckerPunch::Queues.registered?(queue_name)
        Celluloid::Actor[queue_name] = self.class.send(:pool)
        SuckerPunch::Queues.register(queue_name)
      end
    end

    def queue_name
      self.class.to_s.underscore.to_sym
    end
  end
end
