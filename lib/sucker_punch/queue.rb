require 'forwardable'

module SuckerPunch
  class Queue < Concurrent::Synchronization::LockableObject
    extend Forwardable
    include Concurrent::ExecutorService

    DEFAULT_MAX_QUEUE_SIZE = 0 # Unlimited

    DEFAULT_EXECUTOR_OPTIONS = {
      min_threads:     2,
      max_threads:     2,
      idletime:        60, # 1 minute
      auto_terminate:  false # Let shutdown modes handle thread termination
    }.freeze

    QUEUES = Concurrent::Map.new

    def self.find_or_create(name, num_workers = 2, num_jobs_max = nil)
      pool = QUEUES.fetch_or_store(name) do
        options = DEFAULT_EXECUTOR_OPTIONS
          .merge(
            min_threads: num_workers,
            max_threads: num_workers,
            max_queue: num_jobs_max || DEFAULT_MAX_QUEUE_SIZE
          )
        Concurrent::ThreadPoolExecutor.new(options)
      end

      new(name, pool)
    end

    def self.all
      queues = Concurrent::Array.new
      QUEUES.each_pair do |name, pool|
        queues.push new(name, pool)
      end
      queues
    end

    def self.clear
      # susceptible to race conditions--only use in testing
      old = all
      QUEUES.clear
      SuckerPunch::Counter::Busy.clear
      SuckerPunch::Counter::Processed.clear
      SuckerPunch::Counter::Failed.clear
      old.each { |queue| queue.kill }
    end

    def self.stats
      queues = {}

      all.each do |queue|
        queues[queue.name] = {
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

    PAUSE_TIME = STDOUT.tty? ? 0.1 : 0.5

    def self.shutdown_all
      deadline = Time.now + SuckerPunch.shutdown_timeout

      if SuckerPunch::RUNNING.make_false
        # If a job is enqueued right before the script exits
        # (command line, rake task, etc.), the system needs an
        # interval to allow the enqueue jobs to make it in to the system
        # otherwise the queue will look idle
        sleep PAUSE_TIME

        queues = all

        # Issue shutdown to each queue and let them wrap up their work. This
        # prevents new jobs from being enqueued and lets the pool clean up
        # after itself
        queues.each { |queue| queue.shutdown }

        # return if every queue is empty and workers in every queue are idle
        return if queues.all? { |queue| queue.idle? }

        SuckerPunch.logger.info("Pausing to allow workers to finish...")

        remaining = deadline - Time.now

        # Continue to loop through each queue and test if it's idle, while
        # respecting the shutdown timeout
        while remaining > PAUSE_TIME
          return if queues.all? { |queue| queue.idle? }
          sleep PAUSE_TIME
          remaining = deadline - Time.now
        end

        # Queues haven't finished work. Aggressively kill them.
        SuckerPunch.logger.warn("Queued jobs didn't finish before shutdown_timeout...killing remaining jobs")
        queues.each { |queue| queue.kill }
      end
    end

    attr_reader :name

    def_delegators :@pool,
      :max_length,
      :min_length,
      :max_queue,
      :length,
      :queue_length,
      :wait_for_termination#,
      #:idletime,
      #:max_queue,
      #:largest_length,
      #:scheduled_task_count,
      #:completed_task_count,
      #:can_overflow?,
      #:remaining_capacity,
      #:running?,
      #:shuttingdown?

    alias_method :total_workers, :length
    alias_method :enqueued_jobs, :queue_length

    def initialize(name, pool)
      super()
      @running = true
      @name, @pool = name, pool
    end

    def running?
      synchronize { @running }
    end

    def idle?
      enqueued_jobs == 0 && busy_workers == 0
    end

    def ==(other)
      pool == other.pool
    end

    def busy_workers
      SuckerPunch::Counter::Busy.new(name).value
    end

    def idle_workers
      total_workers - busy_workers
    end

    def processed_jobs
      SuckerPunch::Counter::Processed.new(name).value
    end

    def failed_jobs
      SuckerPunch::Counter::Failed.new(name).value
    end

    def post(*args, &block)
      synchronize do
        if @running
          @pool.post(*args, &block)
        else
          false
        end
      end
    end

    def kill
      @pool.kill
    end

    def shutdown
      synchronize { @running = false }
      @pool.shutdown
    end

    protected

    def pool
      @pool
    end
  end
end

