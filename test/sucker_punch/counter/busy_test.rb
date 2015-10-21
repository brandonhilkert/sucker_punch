require 'test_helper'

module SuckerPunch
  module Counter
    class BusyTest < Minitest::Test
      def setup
        @queue = "fake"
      end

      def teardown
        SuckerPunch::Counter::Busy.clear
      end

      def test_counter_can_be_cleared
        SuckerPunch::Counter::Busy.new(@queue).increment
        SuckerPunch::Counter::Busy.clear
        assert_equal 0, SuckerPunch::Counter::Busy.new(@queue).value
      end

      def test_same_counter_is_returned
        c = SuckerPunch::Counter::Busy.new(@queue)
        assert_equal c.counter, SuckerPunch::Counter::Busy::COUNTER[@queue]
      end

      def test_busy_workers_default_is_0
        c = SuckerPunch::Counter::Busy.new(@queue)
        assert_equal 0, c.value
      end

      def test_busy_workers_supports_incrementing_and_decrementing
        c = SuckerPunch::Counter::Busy.new(@queue)
        assert_equal 1, c.increment
        assert_equal 0, c.decrement
      end

    end
  end
end
