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

    BUSY_WORKERS = Concurrent::Map.new do |hash, name| #:nodoc:
      hash.compute_if_absent(name) { Concurrent::AtomicFixnum.new }
    end

    PROCESSED_JOBS = Concurrent::Map.new do |hash, name| #:nodoc:
      hash.compute_if_absent(name) { Concurrent::AtomicFixnum.new }
    end

    FAILED_JOBS = Concurrent::Map.new do |hash, name| #:nodoc:
      hash.compute_if_absent(name) { Concurrent::AtomicFixnum.new }
    end

    def self.find_or_create(name)
      QUEUES.fetch_or_store(name) do
        Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS)
      end
    end

    def self.clear
      QUEUES.clear
      BUSY_WORKERS.clear
      PROCESSED_JOBS.clear
      FAILED_JOBS.clear
    end

    def self.all
      queues = {}

      QUEUES.each_pair do |name, pool|
        busy = BUSY_WORKERS[name].value
        processed = PROCESSED_JOBS[name].value
        failed = FAILED_JOBS[name].value

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


