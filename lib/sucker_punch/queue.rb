module SuckerPunch
  class Queue
    DEFAULT_EXECUTOR_OPTIONS = {
      min_threads:     [2, Concurrent.processor_count].max,
      max_threads:     Concurrent.processor_count * 10,
      auto_terminate:  true,
      idletime:        60, # 1 minute
      max_queue:       0, # unlimited
    }.freeze

    QUEUES = Concurrent::Map.new do |hash, queue_name| #:nodoc:
      hash.compute_if_absent(queue_name) { Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS) }
    end

    BUSY_WORKERS = Concurrent::Map.new do |hash, queue_name| #:nodoc:
      hash.compute_if_absent(queue_name) { Concurrent::AtomicFixnum.new }
    end

    def self.all
      queues = {}

      QUEUES.each_pair do |queue_name, pool|
        busy = BUSY_WORKERS[queue_name],

        queues[queue_name] = {
          "workers" => {
            "total" => pool.length,
            "busy" => busy,
            "idle" => pool.length - busy,
          },
          "jobs" => {
            "processed" => pool.completed_task_count,
            "enqueued" => pool.queue_length
          }
        }
      end

      queues
    end
  end
end


