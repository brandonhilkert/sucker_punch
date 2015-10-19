require 'test_helper'

module SuckerPunch
  class JobTest < Minitest::Test
    def test_run_perform_delegates_to_instance_perform
      assert_equal "fake", FakeLogJob.__run_perform
    end

    def test_processed_jobs_is_incremented_on_successful_completion
      latch = Concurrent::CountDownLatch.new
      4.times{ FakeLogJob.perform_async }
      pool = SuckerPunch::Queue.find("FakeLogJob")
      pool.post { latch.count_down }
      latch.wait(0.1)
      assert_equal 4, SuckerPunch::Queue::PROCESSED_JOBS["FakeLogJob"].value
    end

    def test_failed_jobs_is_incremented_when_job_raises
      latch = Concurrent::CountDownLatch.new
      4.times{ FakeLogJob.perform_async }
      pool = SuckerPunch::Queue.find("FakeLogJob")
      pool.post { latch.count_down }
      latch.wait(0.1)
      assert_equal 4, SuckerPunch::Queue::FAILED_JOBS["FakeErrorJob"].value
    end

    private

    class FakeLogJob
      include SuckerPunch::Job
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

