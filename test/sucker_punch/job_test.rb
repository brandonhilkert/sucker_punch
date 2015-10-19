require 'test_helper'

module SuckerPunch
  class JobTest < Minitest::Test
    def test_run_perform_delegates_to_instance_perform
      assert_equal "fake", FakeLogJob.__run_perform
    end

    private

    class FakeLogJob
      include SuckerPunch::Job
      def perform
        "fake"
      end
    end
  end
end

