require 'test_helper'

module SuckerPunch
  class ShutdownModeTest < Minitest::Test
    def test_default_mode_is_soft
      mode = SuckerPunch::ShutdownMode.mode(nil)
      assert_equal SuckerPunch::ShutdownMode::Soft, mode

      mode = SuckerPunch::ShutdownMode.mode(:unknown)
      assert_equal SuckerPunch::ShutdownMode::Soft, mode
    end

    def test_mode_return_right_mode_class
      mode = SuckerPunch::ShutdownMode.mode(:soft)
      assert_equal SuckerPunch::ShutdownMode::Soft, mode

      mode = SuckerPunch::ShutdownMode.mode(:hard)
      assert_equal SuckerPunch::ShutdownMode::Hard, mode

      mode = SuckerPunch::ShutdownMode.mode(:none)
      assert_equal SuckerPunch::ShutdownMode::None, mode
    end
  end
end
