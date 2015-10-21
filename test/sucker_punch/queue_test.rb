require 'test_helper'

module SuckerPunch
  class QueueTest < Minitest::Test
    def setup
      @queue = "fake"
    end

    def teardown
      SuckerPunch::Queue.clear
    end

    def test_queue_is_created_if_it_doesnt_exist
      SuckerPunch::Queue::QUEUES.clear
      assert SuckerPunch::Queue::QUEUES.empty?
      pool = SuckerPunch::Queue.find_or_create(@queue)
      assert pool.is_a?(Concurrent::ThreadPoolExecutor)
    end

    def test_same_queue_is_returned_on_subsequent_queries
      SuckerPunch::Queue::QUEUES.clear
      pool = SuckerPunch::Queue.find_or_create(@queue)
      assert_equal pool, SuckerPunch::Queue.find_or_create(@queue)
    end

    def test_busy_workers_default_is_0
      atomic = SuckerPunch::Queue::BUSY_WORKERS[@queue]
      assert_equal 0, atomic.value
    end

    def test_busy_workers_supports_incrementing_and_decrementing
      atomic = SuckerPunch::Queue::BUSY_WORKERS[@queue]
      atomic.increment
      assert_equal 1, atomic.value
      atomic.decrement
      assert_equal 0, atomic.value
    end

    def test_processed_jobs_default_is_0
      atomic = SuckerPunch::Queue::PROCESSED_JOBS[@queue]
      assert_equal 0, atomic.value
    end

    def test_processed_jobs_supports_incrementing_and_decrementing
      atomic = SuckerPunch::Queue::PROCESSED_JOBS[@queue]
      atomic.increment
      assert_equal 1, atomic.value
      atomic.decrement
      assert_equal 0, atomic.value
    end

    def test_failed_jobs_default_is_0
      atomic = SuckerPunch::Queue::FAILED_JOBS[@queue]
      assert_equal 0, atomic.value
    end

    def test_failed_jobs_supports_incrementing_and_decrementing
      atomic = SuckerPunch::Queue::FAILED_JOBS[@queue]
      atomic.increment
      assert_equal 1, atomic.value
      atomic.decrement
      assert_equal 0, atomic.value
    end

    def test_clear_removes_queues_and_stats
      SuckerPunch::Queue.find_or_create(@queue)
      SuckerPunch::Queue::BUSY_WORKERS[@queue]
      SuckerPunch::Queue::PROCESSED_JOBS[@queue]
      SuckerPunch::Queue::FAILED_JOBS[@queue]

      refute SuckerPunch::Queue::QUEUES.empty?
      refute SuckerPunch::Queue::BUSY_WORKERS.empty?
      refute SuckerPunch::Queue::PROCESSED_JOBS.empty?
      refute SuckerPunch::Queue::FAILED_JOBS.empty?

      SuckerPunch::Queue.clear

      assert SuckerPunch::Queue::QUEUES.empty?
      assert SuckerPunch::Queue::BUSY_WORKERS.empty?
      assert SuckerPunch::Queue::PROCESSED_JOBS.empty?
      assert SuckerPunch::Queue::FAILED_JOBS.empty?
    end

    def test_returns_queue_stats
      latch = Concurrent::CountDownLatch.new

      # run a job to setup workers
      2.times { FakeNilJob.perform_async }

      pool = SuckerPunch::Queue.find_or_create(FakeNilJob.to_s)
      pool.post { latch.count_down }
      latch.wait(0.1)

      all_stats = SuckerPunch::Queue.all
      stats = all_stats[FakeNilJob.to_s]
      assert stats["workers"]["total"] > 0
      assert stats["workers"]["busy"] == 0
      assert stats["workers"]["idle"] > 0
      assert stats["jobs"]["processed"] > 0
      assert stats["jobs"]["failed"] == 0
      assert stats["jobs"]["enqueued"] == 0
    end

    private

    class FakeNilJob
      include SuckerPunch::Job
      def perform
        nil
      end
    end
  end
end
