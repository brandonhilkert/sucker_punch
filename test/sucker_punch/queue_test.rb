require 'test_helper'

module SuckerPunch
  class QueueTest < Minitest::Test
    def setup
      @queue = "fake"
    end

    def test_queue_is_created_if_it_doesnt_exist
      pool = SuckerPunch::Queue::QUEUES[@queue]
      assert pool.is_a?(Concurrent::ThreadPoolExecutor)
    end

    def test_same_queue_is_returned_on_subsequent_queries
      pool = SuckerPunch::Queue::QUEUES[@queue]
      assert_equal pool, SuckerPunch::Queue::QUEUES[@queue]
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

    def test_provides_finder_method_for_queue
      pool = SuckerPunch::Queue::QUEUES[@queue]
      assert_equal pool, SuckerPunch::Queue.find(@queue)
    end
  end
end
