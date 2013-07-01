require 'thread'

module SuckerPunch
  class Queue
    attr_reader :job
    attr_accessor :pool

    def self.find(job)
      queue = self.new(job)
      Celluloid::Actor[queue.name]
    end

    def initialize(job)
      @job = job
      @pool = nil
      @mutex = Mutex.new
    end

    def register
      @mutex.synchronize {
        unless registered?
          initialize_celluloid_pool
          register_celluloid_pool
          register_queue_with_master_list
        end
      }
    end

    def registered?
      SuckerPunch::Queues.all.include?(name)
    end

    def name
      job.class.to_s.underscore.to_sym
    end

    private

    def initialize_celluloid_pool
      self.pool = job.class.send(:pool)
    end

    def register_celluloid_pool
      Celluloid::Actor[name] = pool
    end

    def register_queue_with_master_list
      SuckerPunch::Queues.register(name)
    end
  end
end


