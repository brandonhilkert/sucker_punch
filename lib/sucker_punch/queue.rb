module SuckerPunch
  class Queue
    DEFAULT_EXECUTOR_OPTIONS = {
      min_threads:     2,
      max_threads:     2,
      idletime:        60, # 1 minute
      max_queue:       0, # unlimited
      auto_terminate:  false # Let shutdown modes handle thread termination
    }.freeze

    QUEUES = Concurrent::Map.new

    def self.find_or_create(name, num_workers = 2)
      QUEUES.fetch_or_store(name) do
        options = DEFAULT_EXECUTOR_OPTIONS.merge({
          min_threads: num_workers,
          max_threads: num_workers
        })
        Concurrent::ThreadPoolExecutor.new(options)
      end
    end

    def self.clear
      QUEUES.clear
      SuckerPunch::Counter::Busy.clear
      SuckerPunch::Counter::Processed.clear
      SuckerPunch::Counter::Failed.clear
    end

    def self.all
      queues = {}

      QUEUES.each_pair do |name, pool|
        queue = new(name, pool)

        queues[name] = {
          "workers" => {
            "total" => queue.total_workers,
            "busy" => queue.busy_workers,
            "idle" => queue.idle_workers,
          },
          "jobs" => {
            "processed" => queue.processed_jobs,
            "failed" => queue.failed_jobs,
            "enqueued" => queue.enqueued_jobs,
          }
        }
      end

      queues
    end

    def initialize(name, pool)
      @name, @pool = name, pool
    end

    def total_workers
      @pool.length
    end

    def busy_workers
      SuckerPunch::Counter::Busy.new(@name).value
    end

    def idle_workers
      total_workers - busy_workers
    end

    def processed_jobs
      SuckerPunch::Counter::Processed.new(@name).value
    end

    def failed_jobs
      SuckerPunch::Counter::Failed.new(@name).value
    end

    def enqueued_jobs
      @pool.queue_length
    end
  end
end


