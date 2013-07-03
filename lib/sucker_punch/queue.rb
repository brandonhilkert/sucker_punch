require 'thread'

module SuckerPunch
  class Queue
    attr_reader :klass
    attr_accessor :pool

    DEFAULT_OPTIONS = { workers: 2 }
    class MaxWorkersExceeded < StandardError; end
    class NotEnoughWorkers < StandardError; end

    def self.find(klass)
      queue = self.new(klass)
      Celluloid::Actor[queue.name]
    end

    def initialize(klass)
      @klass = klass
      @pool = nil
      @mutex = Mutex.new
    end

    def register(workers = DEFAULT_OPTIONS[:workers] )
      raise MaxWorkersExceeded if workers > 100
      raise NotEnoughWorkers if workers < 1

      @mutex.synchronize {
        unless registered?
          initialize_celluloid_pool(workers)
          register_celluloid_pool
          register_queue_with_master_list
        end
      }
      self.class.find(klass)
    end

    def registered?
      SuckerPunch::Queues.all.include?(name)
    end

    def name
      klass.to_s.underscore.to_sym
    end

    private

    def initialize_celluloid_pool(workers)
      self.pool = klass.send(:pool, { size: workers })
    end

    def register_celluloid_pool
      Celluloid::Actor[name] = pool
    end

    def register_queue_with_master_list
      SuckerPunch::Queues.register(name)
    end
  end
end


