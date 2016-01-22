require 'test_helper'

module SuckerPunch
  class JobTest < Minitest::Test
    def setup
      SuckerPunch::Queue.clear
    end

    def teardown
      SuckerPunch::Queue.clear
      SuckerPunch::RUNNING.make_true
    end

    def test_perform_async_runs_job_asynchronously
      arr = Concurrent::Array.new
      latch = Concurrent::CountDownLatch.new
      FakeLatchJob.perform_async(arr, latch)
      latch.wait(1)
      assert_equal 1, arr.size
    end

    def test_job_isnt_run_with_perform_async_if_sucker_punch_is_shutdown
      SuckerPunch::RUNNING.make_false
      arr = Concurrent::Array.new
      latch = Concurrent::CountDownLatch.new
      FakeLatchJob.perform_async(arr, latch)
      latch.wait(1)
      assert_equal 0, arr.size
    end

    def test_perform_in_runs_job_in_future
      arr = Concurrent::Array.new
      latch = Concurrent::CountDownLatch.new
      FakeLatchJob.perform_in(0.1, arr, latch)
      latch.wait(1)
      assert_equal 1, arr.size
    end

    def test_job_isnt_run_with_perform_in_if_sucker_punch_is_shutdown
      SuckerPunch::RUNNING.make_false
      arr = Concurrent::Array.new
      latch = Concurrent::CountDownLatch.new
      FakeLatchJob.perform_in(0.1, arr, latch)
      latch.wait(1)
      assert_equal 0, arr.size
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
      job_class = Class.new(FakeBusyJob)
      latch1 = Concurrent::CountDownLatch.new
      latch2 = Concurrent::CountDownLatch.new
      job_class.perform_async(latch1, latch2)
      latch1.wait(1)
      actual = SuckerPunch::Counter::Busy.new(job_class.to_s).value
      latch2.count_down
      assert actual > 0
    end

    def test_processed_jobs_is_incremented_on_successful_completion
      job_class = Class.new(FakeLatchJob)
      jobs = 3
      latch = Concurrent::CountDownLatch.new(jobs)
      jobs.times{ job_class.perform_async([], latch) }
      latch.wait(1)
      queue = SuckerPunch::Queue.find_or_create(job_class.to_s)
      queue.shutdown
      queue.wait_for_termination(1)
      assert SuckerPunch::Counter::Processed.new(job_class.to_s).value == jobs
    end

    def test_processed_jobs_is_incremented_when_enqueued_with_perform_in
      job_class = Class.new(FakeLatchJob)
      latch = Concurrent::CountDownLatch.new
      job_class.perform_in(0.0, [], latch)
      latch.wait(1)
      queue = SuckerPunch::Queue.find_or_create(job_class.to_s)
      queue.shutdown
      queue.wait_for_termination(1)
      assert SuckerPunch::Counter::Processed.new(job_class.to_s).value == 1
    end

    def test_failed_jobs_is_incremented_when_job_raises
      job_class = Class.new(FakeErrorJob)
      jobs = 3
      jobs.times{ job_class.perform_async }
      queue = SuckerPunch::Queue.find_or_create(job_class.to_s)
      queue.shutdown
      queue.wait_for_termination(1)
      assert SuckerPunch::Counter::Failed.new(job_class.to_s).value == jobs
    end

    private

    class FakeLatchJob
      include SuckerPunch::Job
      def perform(arr, latch)
        arr.push true
        latch.count_down
      end
    end

    class FakeBusyJob
      include SuckerPunch::Job
      def perform(latch1, latch2)
        # trigger the first latch to tell the test we're working
        latch1.count_down
        # wait for the test to tell us we can finish
        latch2.wait(1)
      end
    end

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

