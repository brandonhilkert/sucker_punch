require 'test_helper'

module SuckerPunch
  class AsyncSyntaxTest < Minitest::Test
    def setup
      require 'sucker_punch/async_syntax'
      SuckerPunch::Queue.clear
    end

    def teardown
      SuckerPunch::Queue.clear
    end

    def test_perform_async_runs_job_asynchronously
      arr = Concurrent::Array.new
      latch = Concurrent::CountDownLatch.new
      FakeLatchJob.new.async.perform(arr, latch)
      latch.wait(0.2)
      assert_equal 1, arr.size
    end

    private

    class FakeLatchJob
      include SuckerPunch::Job

      def perform(arr, latch)
        arr.push true
        latch.count_down
      end
    end
  end
end
