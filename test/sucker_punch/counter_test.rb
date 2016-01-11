require 'test_helper'

module SuckerPunch
  class CounterTest < Minitest::Test
    def setup
      @queue = "fake"
      SuckerPunch::Queue.clear
    end

    def teardown
      SuckerPunch::Queue.clear
      SuckerPunch::Counter::Busy.clear
      SuckerPunch::Counter::Failed.clear
      SuckerPunch::Counter::Processed.clear
    end

    def test_busy_counter_can_be_cleared
      SuckerPunch::Counter::Busy.new(@queue).increment
      SuckerPunch::Counter::Busy.clear
      assert_equal 0, SuckerPunch::Counter::Busy.new(@queue).value
    end

    def test_same_busy_counter_is_returned
      c = SuckerPunch::Counter::Busy.new(@queue)
      assert_equal c.counter, SuckerPunch::Counter::Busy::COUNTER[@queue]
    end

    def test_busy_counter_default_is_0
      c = SuckerPunch::Counter::Busy.new(@queue)
      assert_equal 0, c.value
    end

    def test_busy_counter_supports_incrementing_and_decrementing
      c = SuckerPunch::Counter::Busy.new(@queue)
      assert_equal 1, c.increment
      assert_equal 0, c.decrement
    end

    def test_processed_counter_can_be_cleared
      SuckerPunch::Counter::Processed.new(@queue).increment
      SuckerPunch::Counter::Processed.clear
      assert_equal 0, SuckerPunch::Counter::Processed.new(@queue).value
    end

    def test_same_counter_is_returned_for_processed
      c = SuckerPunch::Counter::Processed.new(@queue)
      assert_equal c.counter, SuckerPunch::Counter::Processed::COUNTER[@queue]
    end

    def test_processed_counter_default_is_0
      c = SuckerPunch::Counter::Processed.new(@queue)
      assert_equal 0, c.value
    end

    def test_processed_counter_supports_incrementing_and_decrementing
      c = SuckerPunch::Counter::Processed.new(@queue)
      assert_equal 1, c.increment
      assert_equal 0, c.decrement
    end

    def test_failed_counter_can_be_cleared
      SuckerPunch::Counter::Failed.new(@queue).increment
      SuckerPunch::Counter::Failed.clear
      assert_equal 0, SuckerPunch::Counter::Failed.new(@queue).value
    end

    def test_same_counter_is_returned_for_failed
      c = SuckerPunch::Counter::Failed.new(@queue)
      assert_equal c.counter, SuckerPunch::Counter::Failed::COUNTER[@queue]
    end

    def test_failed_counter_default_is_0
      c = SuckerPunch::Counter::Failed.new(@queue)
      assert_equal 0, c.value
    end

    def test_failed_counter_supports_incrementing_and_decrementing
      c = SuckerPunch::Counter::Failed.new(@queue)
      assert_equal 1, c.increment
      assert_equal 0, c.decrement
    end
  end
end
