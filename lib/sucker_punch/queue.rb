module SuckerPunch
  class Queue
    DEFAULT_EXECUTOR_OPTIONS = {
      min_threads:     2,
      max_threads:     2,
      auto_terminate:  true,
      idletime:        60, # 1 minute
      max_queue:       0, # unlimited
    }.freeze

    QUEUES = Concurrent::Map.new

    def self.find_or_create(name, num_workers = 2)
      QUEUES.fetch_or_store(name) do
        options = DEFAULT_EXECUTOR_OPTIONS.merge({
          min_threads: 0,
          max_threads: num_workers,
          auto_terminate: false
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
        busy = SuckerPunch::Counter::Busy.new(name).value
        processed = SuckerPunch::Counter::Processed.new(name).value
        failed = SuckerPunch::Counter::Failed.new(name).value

        queues[name] = {
          "workers" => {
            "total" => pool.length,
            "busy" => busy,
            "idle" => pool.length - busy,
          },
          "jobs" => {
            "processed" => processed,
            "failed" => failed,
            "enqueued" => pool.queue_length
          }
        }
      end

      queues
    end
  end
end


