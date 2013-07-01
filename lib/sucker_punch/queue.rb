module SuckerPunch
  class Queue
    attr_reader :job
    attr_accessor :pool

    def initialize(job)
      @job = job
      @pool = nil
    end

    def register
      unless registered?
        initialize_celluloid_pool
        register_celluloid_pool
        register_queue_with_master_list
      end
    end

    def registered?
      SuckerPunch::Queues.all.include?(queue_name)
    end

    private

    def initialize_celluloid_pool
      self.pool = job.class.send(:pool)
    end

    def register_celluloid_pool
      Celluloid::Actor[queue_name] = pool
    end

    def register_queue_with_master_list
      SuckerPunch::Queues.register(queue_name)
    end

    def queue_name
      job.class.to_s.underscore.to_sym
    end
  end
end


