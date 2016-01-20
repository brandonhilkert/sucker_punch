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
      queue = SuckerPunch::Queue.find_or_create(@queue)
      assert queue.send(:pool).is_a?(Concurrent::ThreadPoolExecutor)
    end

    def test_queue_is_created_with_2_workers
      queue = SuckerPunch::Queue.find_or_create(@queue)
      assert_equal 2, queue.max_length
      assert_equal 2, queue.min_length
    end

    def test_queue_num_workers_can_be_set
      queue = SuckerPunch::Queue.find_or_create(@queue, 4)
      assert_equal 4, queue.max_length
      assert_equal 4, queue.min_length
    end

    def test_same_queue_is_returned_on_subsequent_queries
      queue = SuckerPunch::Queue.find_or_create(@queue)
      assert_equal queue, SuckerPunch::Queue.find_or_create(@queue)
    end

    def test_all_returns_all_instances_of_a_queue
      queue1 = SuckerPunch::Queue.find_or_create("fake")
      queue2 = SuckerPunch::Queue.find_or_create("other_fake")
      assert SuckerPunch::Queue.all.is_a?(Array)
      assert SuckerPunch::Queue.all.first.is_a?(SuckerPunch::Queue)
      assert SuckerPunch::Queue.all.include?(queue1)
      assert SuckerPunch::Queue.all.include?(queue2)
    end

    def test_clear_removes_queues_and_stats
      SuckerPunch::Queue.find_or_create(@queue)
      SuckerPunch::Counter::Busy.new(@queue).increment
      SuckerPunch::Counter::Processed.new(@queue).increment
      SuckerPunch::Counter::Failed.new(@queue).increment

      SuckerPunch::Queue.clear

      assert SuckerPunch::Counter::Busy.new(@queue).value == 0
      assert SuckerPunch::Counter::Processed.new(@queue).value == 0
      assert SuckerPunch::Counter::Failed.new(@queue).value == 0
    end

    def test_returns_queue_stats
      latch = Concurrent::CountDownLatch.new(2)

      2.times{ FakeLatchJob.perform_async(latch) }
      latch.wait(2)

      all_stats = SuckerPunch::Queue.stats
      stats = all_stats[FakeLatchJob.to_s]
      assert stats["workers"]["total"] > 0
      assert stats["workers"]["busy"] == 0
      assert stats["workers"]["idle"] > 0
      assert stats["jobs"]["processed"] > 0
      assert stats["jobs"]["failed"] == 0
      assert stats["jobs"]["enqueued"] == 0
    end

    def test_queue_name_is_accessible
      queue = SuckerPunch::Queue.find_or_create(FakeNilJob.to_s)
      assert_equal "SuckerPunch::QueueTest::FakeNilJob", queue.name
    end

    def test_default_running_state_is_true
      queue = SuckerPunch::Queue.find_or_create(FakeNilJob.to_s)
      assert_equal true, queue.running?
    end

    def test_jobs_can_be_posted_to_pool
      arr = []
      fake_pool = FakePool.new
      queue = SuckerPunch::Queue.new "fake", fake_pool
      queue.post(1, 2) { |args| arr.push args }
      assert_equal [1, 2], arr.first
    end

    def test_jobs_arent_posted_if_queue_isnt_running
      arr = []
      fake_pool = FakePool.new
      queue = SuckerPunch::Queue.new "fake", fake_pool
      queue.kill
      queue.post(1, 2) { |args| arr.push args }
      assert arr.empty?
    end

    def test_kill_sends_kill_to_pool
      fake_pool = FakePool.new
      queue = SuckerPunch::Queue.new "fake", fake_pool
      queue.kill
      assert_equal :kill, fake_pool.signals.first
    end

    def test_shutdown_sends_shutdown_to_pool
      fake_pool = FakePool.new
      queue = SuckerPunch::Queue.new "fake", fake_pool
      queue.shutdown
      assert_equal :shutdown, fake_pool.signals.first
    end

    private

    class FakeLatchJob
      include SuckerPunch::Job
      def perform(latch)
        latch.count_down
      end
    end

    class FakeNilJob
      include SuckerPunch::Job
      def perform
        nil
      end
    end

    class FakePool
      attr_accessor :signals
      def initialize
        @signals = []
      end

      def post(*args, &block)
        if block_given?
          block.call(args)
        end
      end

      def kill
        self.signals.push :kill
      end

      def shutdown
        self.signals.push :shutdown
      end
    end
  end
end
