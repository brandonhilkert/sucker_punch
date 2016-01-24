require 'forwardable'

module SuckerPunch
  class Queue < Concurrent::Synchronization::LockableObject
    extend Forwardable
    include Concurrent::ExecutorService

    DEFAULT_EXECUTOR_OPTIONS = {
      min_threads:     2,
      max_threads:     2,
      idletime:        60, # 1 minute
      max_queue:       0, # unlimited
      auto_terminate:  false # Let shutdown modes handle thread termination
    }.freeze

    QUEUES = Concurrent::Map.new

    def self.find_or_create(name, num_workers = 2)
      pool = QUEUES.fetch_or_store(name) do
        options = DEFAULT_EXECUTOR_OPTIONS.merge({
          min_threads: num_workers,
          max_threads: num_workers
        })
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

    def self.shutdown_all
      if SuckerPunch::RUNNING.make_false

        queues = all
        latch = Concurrent::CountDownLatch.new(queues.length)

        queues.each do |queue|
          queue.post(latch) { |l| l.count_down }
          queue.shutdown
        end

        unless latch.wait(SuckerPunch.shutdown_timeout)
          queues.each { |queue| queue.kill }
          SuckerPunch.logger.info("Queued jobs didn't finish before shutdown_timeout...killing remaining jobs")
        end
      end
    end

    attr_reader :name

    def_delegators :@pool,
      :max_length,
      :min_length,
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
      if can_initiate_shutdown?
        @pool.kill
      end
    end

    def shutdown
      if can_initiate_shutdown?
        @pool.shutdown
      end
    end

    protected

    def pool
      @pool
    end

    private

    def can_initiate_shutdown?
      synchronize do
        if @running
          @running = false
          true
        else
          false
        end
      end
    end
  end
end

