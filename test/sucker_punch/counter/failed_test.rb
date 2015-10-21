require 'test_helper'

module SuckerPunch
  module Counter
    class FailedTest < Minitest::Test
      def setup
        @queue = "fake"
      end

      def teardown
        SuckerPunch::Counter::Busy.clear
      end

      def test_counter_can_be_cleared
        SuckerPunch::Counter::Failed.new(@queue).increment
        SuckerPunch::Counter::Failed.clear
        assert_equal 0, SuckerPunch::Counter::Failed.new(@queue).value
      end

      def test_same_counter_is_returned
        c = SuckerPunch::Counter::Failed.new(@queue)
        assert_equal c.counter, SuckerPunch::Counter::Failed::COUNTER[@queue]
      end

      def test_failed_workers_default_is_0
        c = SuckerPunch::Counter::Failed.new(@queue)
        assert_equal 0, c.value
      end

      def test_failed_workers_supports_incrementing_and_decrementing
        c = SuckerPunch::Counter::Failed.new(@queue)
        assert_equal 1, c.increment
        assert_equal 0, c.decrement
      end

    end
  end
end

