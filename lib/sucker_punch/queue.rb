require 'thread'

module SuckerPunch
  class Queue
    attr_reader :klass

    REGISTRY_PREFIX = "sucker_punch"
    MaxWorkersExceeded = Class.new(StandardError)
    NotEnoughWorkers = Class.new(StandardError)

    def self.find(klass)
      queue = self.new(klass)
      Celluloid::Actor[queue.name]
    end

    def self.clear_all
      Celluloid::Actor.all.each do |actor|
        registered_name = actor.registered_name.to_s
        matches = registered_name.match(REGISTRY_PREFIX).to_a

        if matches.any?
          Celluloid::Actor.delete(registered_name)
        end
      end
    end

    def initialize(klass)
      @klass = klass
      @mutex = Mutex.new
    end

    def register(num_workers = nil)
      @mutex.synchronize {
        unless registered?
          pool = initialize_celluloid_pool(num_workers)
          register_celluloid_pool(pool)
        end
      }
      self.class.find(klass)
    end

    def registered?
      Celluloid::Actor.registered.include?(name.to_sym)
    end

    def name
      klass_name = klass.to_s.underscore
      "#{REGISTRY_PREFIX}_#{klass_name}".to_sym
    end

    private

    def initialize_celluloid_pool(num_workers)
      if num_workers
        raise MaxWorkersExceeded if num_workers > 200
        raise NotEnoughWorkers if num_workers < 1
      end
      pool_options = {}
      pool_options = pool_options.merge({ size: num_workers })
      klass.pool(pool_options)
    end

    def register_celluloid_pool(pool)
      Celluloid::Actor[name] = pool
    end
  end
end


