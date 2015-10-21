require 'test_helper'

module SuckerPunch
  module Counter
    class ProcessedTest < Minitest::Test
      def setup
        @queue = "fake"
      end

      def teardown
        SuckerPunch::Counter::Busy.clear
      end

      def test_counter_can_be_cleared
        SuckerPunch::Counter::Processed.new(@queue).increment
        SuckerPunch::Counter::Processed.clear
        assert_equal 0, SuckerPunch::Counter::Processed.new(@queue).value
      end

      def test_same_counter_is_returned
        c = SuckerPunch::Counter::Processed.new(@queue)
        assert_equal c.counter, SuckerPunch::Counter::Processed::COUNTER[@queue]
      end

      def test_processed_workers_default_is_0
        c = SuckerPunch::Counter::Processed.new(@queue)
        assert_equal 0, c.value
      end

      def test_processed_workers_supports_incrementing_and_decrementing
        c = SuckerPunch::Counter::Processed.new(@queue)
        assert_equal 1, c.increment
        assert_equal 0, c.decrement
      end

    end
  end
end


