require 'test_helper'

module SuckerPunch
  class JobTest < Minitest::Test
    def teardown
      SuckerPunch::Queue.clear
    end

    def test_default_workers_is_2
      assert_equal 2, FakeLogJob.num_workers
    end

    def test_can_set_workers_count
      FakeLogJob.workers(4)
      assert_equal 4, FakeLogJob.num_workers
      FakeLogJob.workers(2)
    end

    def test_logger_is_accessible_from_instance
      SuckerPunch.logger = SuckerPunch.default_logger
      assert_equal SuckerPunch.logger, FakeLogJob.new.logger
      SuckerPunch.logger = nil
    end

    def test_num_workers_can_be_set_by_worker_method
      assert_equal 4, FakeWorkerJob.num_workers
    end

    def test_num_workers_is_set_when_enqueueing_job_immediately
      FakeWorkerJob.perform_async
      pool = SuckerPunch::Queue::QUEUES[FakeWorkerJob.to_s]
      assert_equal 4, pool.max_length
      assert_equal 4, pool.min_length
    end

    def test_num_workers_is_set_when_enqueueing_job_in_future
      FakeWorkerJob.perform_in(30)
      pool = SuckerPunch::Queue::QUEUES[FakeWorkerJob.to_s]
      assert_equal 4, pool.max_length
      assert_equal 4, pool.min_length
    end

    def test_run_perform_delegates_to_instance_perform
      assert_equal "fake", FakeLogJob.__run_perform
    end

    def test_busy_workers_is_incremented_during_job_execution
      FakeSlowJob.perform_async
      sleep 0.1
      assert SuckerPunch::Counter::Busy.new(FakeSlowJob.to_s).value > 0
    end

    def test_processed_jobs_is_incremented_on_successful_completion
      latch = Concurrent::CountDownLatch.new
      2.times{ FakeLogJob.perform_async }
      queue = SuckerPunch::Queue.find_or_create(FakeLogJob.to_s)
      queue.pool.post { latch.count_down }
      latch.wait(0.5)
      assert SuckerPunch::Counter::Processed.new(FakeLogJob.to_s).value > 0
    end

    def test_failed_jobs_is_incremented_when_job_raises
      latch = Concurrent::CountDownLatch.new
      2.times{ FakeErrorJob.perform_async }
      queue = SuckerPunch::Queue.find_or_create(FakeErrorJob.to_s)
      queue.pool.post { latch.count_down }
      latch.wait(0.5)
      assert SuckerPunch::Counter::Failed.new(FakeErrorJob.to_s).value > 0
    end

    private

    class FakeSlowJob
      include SuckerPunch::Job
      def perform
        sleep 0.3
      end
    end

    class FakeLogJob
      include SuckerPunch::Job
      def perform
        "fake"
      end
    end

    class FakeWorkerJob
      include SuckerPunch::Job
      workers 4
      def perform
        "fake"
      end
    end

    class FakeErrorJob
      include SuckerPunch::Job
      def perform
        raise "error"
      end
    end
  end
end

